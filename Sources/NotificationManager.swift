import Foundation
import UserNotifications
import UIKit

class NotificationManager: NSObject, ObservableObject, UNUserNotificationCenterDelegate {
    @Published var isAuthorized = false
    
    // Reference to WaterReminderManager for progress tracking
    weak var waterReminderManager: WaterReminderManager?
    
    override init() {
        super.init()
        UNUserNotificationCenter.current().delegate = self
        setupNotificationCategories()
        checkAuthorizationStatus()
        setupAppLifecycleObservers()
    }
    
    private func setupAppLifecycleObservers() {
        // Listen for app lifecycle events to ensure notifications persist
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(appDidBecomeActive),
            name: UIApplication.didBecomeActiveNotification,
            object: nil
        )
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(appWillEnterForeground),
            name: UIApplication.willEnterForegroundNotification,
            object: nil
        )
    }
    
    @objc private func appDidBecomeActive() {
        print("📱 App became active - checking notification status")
        // Small delay to ensure system is ready
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.debugNotificationStatus()
        }
    }
    
    @objc private func appWillEnterForeground() {
        print("📱 App will enter foreground - verifying notifications")
        // This ensures notifications are still active when returning to the app
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            self.debugNotificationStatus()
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    func setupNotificationCategories() {
        // Create notification actions for water logging
        let drinkOneCupAction = UNNotificationAction(
            identifier: "DRINK_ONE_CUP",
            title: "+1 Cup 💧",
            options: [] // Background execution - no app opening
        )
        
        let drinkTwoCupsAction = UNNotificationAction(
            identifier: "DRINK_TWO_CUPS",
            title: "+2 Cups 💧💧",
            options: [] // Background execution - no app opening
        )
        
        let snoozeAction = UNNotificationAction(
            identifier: "SNOOZE",
            title: "Snooze 15 min ⏰",
            options: []
        )
        
        // Create notification category with custom actions
        let waterReminderCategory = UNNotificationCategory(
            identifier: "WATER_REMINDER",
            actions: [drinkOneCupAction, drinkTwoCupsAction, snoozeAction],
            intentIdentifiers: [],
            options: [.customDismissAction]
        )
        
        // Register the category
        UNUserNotificationCenter.current().setNotificationCategories([waterReminderCategory])
        print("✅ Notification categories set up successfully")
    }
    
    func requestNotificationPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { [weak self] granted, error in
            DispatchQueue.main.async {
                self?.isAuthorized = granted
                print("Notification permission granted: \(granted)")
            }
            
            if let error = error {
                print("Notification permission error: \(error)")
            } else {
                print("Notification permission request completed successfully")
            }
        }
    }
    
    func checkAuthorizationStatus() {
        UNUserNotificationCenter.current().getNotificationSettings { [weak self] settings in
            DispatchQueue.main.async {
                self?.isAuthorized = settings.authorizationStatus == .authorized
            }
        }
    }
    
    // MARK: - Direct Water Intake Recording
    private func handleWaterIntakeAction(amount: Double) {
        print("🔔 HandleWaterIntakeAction called with amount: \(amount)")
        
        // Record the water intake first
        recordWaterIntakeDirectly(amount: amount)
        
        // Don't try to open the app from notification action - it has limitations
        // Instead, just record the action and let the user manually open the app
        // The app will handle the reset when it becomes active
        print("📱 Water intake recorded. User can manually open app to see updated progress.")
    }
    
    private func openApp() {
        print("📱 Attempting to open app...")
        
        // Set a flag in UserDefaults to indicate user tapped +1/+2
        UserDefaults.standard.set(true, forKey: "notificationActionTapped")
        UserDefaults.standard.synchronize()
        
        // Try to open the app using URL scheme
        if let url = URL(string: "waterreminder://open") {
            DispatchQueue.main.async {
                if UIApplication.shared.canOpenURL(url) {
                    UIApplication.shared.open(url, options: [:]) { success in
                        print("📱 App opened via URL scheme: \(success)")
                    }
                } else {
                    print("📱 Cannot open URL scheme - user will need to manually open app")
                }
            }
        }
    }
    
    private func isFirstTapOfDay() -> Bool {
        let defaults = UserDefaults.standard
        let currentIntake = defaults.double(forKey: "currentWaterIntake")
        
        // If there's no water intake recorded, this is definitely the first tap of day
        if currentIntake == 0 {
            print("🔍 First tap check - No water intake recorded, this is first tap")
            return true
        }
        
        // Check if we have a lastDrinkTime in UserDefaults
        let lastDrinkFromDefaults: Date?
        if let lastDrinkData = defaults.data(forKey: "lastDrinkTime"),
           let lastDrinkTime = try? JSONDecoder().decode(Date.self, from: lastDrinkData) {
            lastDrinkFromDefaults = lastDrinkTime
        } else {
            lastDrinkFromDefaults = nil
        }
        
        // Use the more recent lastDrinkTime
        let mostRecentLastDrink = lastDrinkFromDefaults
        
        guard let lastDrink = mostRecentLastDrink else {
            // No last drink time recorded, but there's water intake - don't reset
            print("🔍 First tap check - No last drink time, but has intake - not first tap")
            return false
        }
        
        let calendar = Calendar.current
        let isNewDay = !calendar.isDate(lastDrink, inSameDayAs: Date())
        
        print("🔍 First tap check - Current intake: \(currentIntake), Last drink: \(lastDrink), Is new day: \(isNewDay)")
        
        return isNewDay
    }
    
    private func openAppForFirstTapOfDay(amount: Double) {
        print("📱 Opening app for first tap of day")
        
        // Reset daily progress first (clear old progress)
        let defaults = UserDefaults.standard
        defaults.set(0.0, forKey: "currentWaterIntake")
        defaults.removeObject(forKey: "lastDrinkTime")
        defaults.removeObject(forKey: "goalAchievedDate")
        defaults.set(Date(), forKey: "lastResetDate")
        defaults.synchronize()
        
        // Record the water intake after reset
        recordWaterIntakeDirectly(amount: amount)
        
        // Cancel all pending notifications
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
        
        // Schedule today's remaining notifications and tomorrow's first notification
        scheduleNotificationsForTodayAndTomorrow()
        
        // Open the app
        DispatchQueue.main.async {
            if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
               let window = windowScene.windows.first {
                window.makeKeyAndVisible()
            }
        }
    }
    
    private static var globalSchedulingInProgress = false
    private static var lastSchedulingTime: TimeInterval = 0
    
    func scheduleNotificationsForTodayAndTomorrow() {
        let currentTime = Date().timeIntervalSince1970
        
        // Prevent multiple rapid calls within 0.2 seconds
        guard currentTime - NotificationManager.lastSchedulingTime > 0.2 else {
            print("⏸️ Scheduling too frequent - skipping duplicate call (last: \(NotificationManager.lastSchedulingTime), current: \(currentTime))")
            return
        }
        
        NotificationManager.globalSchedulingInProgress = true
        NotificationManager.lastSchedulingTime = currentTime
        print("🔄 SCHEDULING RECURRING DAILY REMINDERS")
        
        // Cancel ALL existing notifications
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
        // Cancelled all existing notifications
        
        // Get current settings
        let defaults = UserDefaults.standard
        let interval = defaults.double(forKey: "reminderInterval")
        
        // Read start and end times as Date objects (stored as JSON data)
        let calendar = Calendar.current
        let actualStartTime: Double
        let actualEndTime: Double
        
        if let startTimeData = defaults.data(forKey: "startTime"),
           let startTimeDate = try? JSONDecoder().decode(Date.self, from: startTimeData) {
            let hour = calendar.component(.hour, from: startTimeDate)
            let minute = calendar.component(.minute, from: startTimeDate)
            actualStartTime = Double(hour) + Double(minute) / 60.0
        } else {
            actualStartTime = 8.0  // Default 8 AM
        }
        
        if let endTimeData = defaults.data(forKey: "endTime"),
           let endTimeDate = try? JSONDecoder().decode(Date.self, from: endTimeData) {
            let hour = calendar.component(.hour, from: endTimeDate)
            let minute = calendar.component(.minute, from: endTimeDate)
            actualEndTime = Double(hour) + Double(minute) / 60.0
        } else {
            actualEndTime = 20.0   // Default 8 PM
        }
        
        // Ensure we don't exceed iOS 64 notification limit
        let maxInterval = 1800.0  // 30 minutes minimum to stay within limit
        let actualInterval = max(interval, maxInterval)
        
        print("📊 Settings - Start: \(actualStartTime), End: \(actualEndTime), Original Interval: \(interval), Actual Interval: \(actualInterval)")
        
        let today = Date()
        
        // Calculate the first notification time for today (start time)
        let startHour = Int(actualStartTime)
        let startMinute = Int((actualStartTime - Double(startHour)) * 60)
        let firstNotificationToday = calendar.date(bySettingHour: startHour, minute: startMinute, second: 0, of: today) ?? today
        
        // Calculate the end time for today
        let endHour = Int(actualEndTime)
        let endMinute = Int((actualEndTime - Double(endHour)) * 60)
        let endTimeToday = calendar.date(bySettingHour: endHour, minute: endMinute, second: 0, of: today) ?? today
        
        print("📊 Current time: \(today)")
        print("📊 First notification today: \(firstNotificationToday)")
        print("📊 End time today: \(endTimeToday)")
        
        // Schedule today's notifications at the specified interval
        var currentNotificationTime = firstNotificationToday
        var todayNotificationsScheduled = 0
        while currentNotificationTime <= endTimeToday {
            if currentNotificationTime > Date() { // Only schedule future notifications
                print("📅 Scheduling today's notification for: \(currentNotificationTime)")
                scheduleWaterReminder(at: currentNotificationTime)
                todayNotificationsScheduled += 1
            }
            currentNotificationTime = currentNotificationTime.addingTimeInterval(actualInterval)
        }
        print("📊 Scheduled \(todayNotificationsScheduled) notifications for today")
        
        // Immediately check if today's notifications are still there
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.checkTodayNotificationsCount()
        }
        
        // Schedule next 1 day with "Good Morning!" notifications (reduced to avoid iOS 64 notification limit)
        for dayOffset in 1...1 {
            let futureDate = calendar.date(byAdding: .day, value: dayOffset, to: today) ?? today
            let firstNotificationFuture = calendar.date(bySettingHour: startHour, minute: startMinute, second: 0, of: futureDate) ?? futureDate
            let endTimeFuture = calendar.date(bySettingHour: endHour, minute: endMinute, second: 0, of: futureDate) ?? futureDate
            
            currentNotificationTime = firstNotificationFuture
            while currentNotificationTime <= endTimeFuture {
                print("📅 Scheduling day \(dayOffset) notification for: \(currentNotificationTime)")
                scheduleTomorrowNotification(at: currentNotificationTime)
                currentNotificationTime = currentNotificationTime.addingTimeInterval(actualInterval)
            }
        }
        
        print("✅ Scheduled notifications for today and next 1 day")
        
        // Reset the flag after a short delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            NotificationManager.globalSchedulingInProgress = false
        }
    }
    
    private func recordWaterIntakeDirectly(amount: Double) {
        print("🔔 RecordWaterIntakeDirectly called with amount: \(amount)")
        let defaults = UserDefaults.standard
        
        // Get current water intake and goal
        let currentIntake = defaults.double(forKey: "currentWaterIntake")
        let currentGoal = defaults.double(forKey: "waterIntakeGoal")
        let newIntake = currentIntake + amount
        let goalToUse = currentGoal > 0 ? currentGoal : 8.0
        
        print("🔔 BEFORE: UserDefaults currentWaterIntake: \(currentIntake)")
        print("🔔 ADDING: \(amount) cups")
        print("🔔 AFTER: Should be \(newIntake) cups")
        
        // Check if goal was just achieved (wasn't achieved before, but is now)
        let wasGoalAchieved = currentIntake >= goalToUse
        let isGoalNowAchieved = newIntake >= goalToUse
        
        print("🔔 Goal check - Previous: \(currentIntake), Current: \(newIntake), Goal: \(goalToUse)")
        print("🔔 Goal check - Was achieved: \(wasGoalAchieved), Is now achieved: \(isGoalNowAchieved)")
        print("🔔 Goal check - Comparison: \(newIntake) >= \(goalToUse) = \(newIntake >= goalToUse)")
        print("🔔 Goal check - Difference: \(newIntake - goalToUse)")
        
        // Save updated water intake and preserve goal
        defaults.set(newIntake, forKey: "currentWaterIntake")
        if currentGoal > 0 {
            defaults.set(currentGoal, forKey: "waterIntakeGoal")
        } else {
            defaults.set(8.0, forKey: "waterIntakeGoal") // Default goal
        }
        // Save lastDrinkTime as JSON-encoded Date (same format as WaterReminderManager.saveSettings)
        if let encoded = try? JSONEncoder().encode(Date()) {
            defaults.set(encoded, forKey: "lastDrinkTime")
        }
        
        // Add a special marker to indicate this was updated by notification action
        defaults.set(Date().timeIntervalSince1970, forKey: "lastNotificationActionTime")
        defaults.set(newIntake, forKey: "lastNotificationActionIntake")
        
        defaults.synchronize()
        
        print("📊 Water intake updated: \(currentIntake) -> \(newIntake), goal: \(goalToUse)")
        
        // Verify the save worked
        let verifyIntake = defaults.double(forKey: "currentWaterIntake")
        print("🔔 VERIFICATION: UserDefaults now has: \(verifyIntake) cups")
        
        if verifyIntake == newIntake {
            print("✅ Notification action save SUCCESS")
        } else {
            print("❌ Notification action save FAILED - expected \(newIntake), got \(verifyIntake)")
        }
        
        // Send congratulations notification if goal was just achieved
        // Check for goal achievement (allowing for small floating point differences)
        if !wasGoalAchieved && isGoalNowAchieved {
            print("🎉 GOAL ACHIEVED FROM NOTIFICATION ACTION! Sending congratulations notification")
            sendGoalAchievementNotification(currentIntake: newIntake, goal: goalToUse)
            
            // Cancel all remaining notifications for today since goal is reached
            print("🎯 Goal reached! Canceling all remaining notifications for today")
            cancelRemainingNotificationsForToday()
        } else if wasGoalAchieved && isGoalNowAchieved {
            print("🎯 Goal was already achieved, no new congratulations notification")
        } else {
            print("🎯 Goal not yet achieved, continuing...")
        }
        
        // Post notification for app to update UI
        NotificationCenter.default.post(name: NSNotification.Name("WaterIntakeRecorded"), object: ["amount": amount])
    }
    
    // MARK: - Goal Achievement Notification
    func sendGoalAchievementNotificationFromApp(currentIntake: Double, goal: Double) {
        sendGoalAchievementNotification(currentIntake: currentIntake, goal: goal)
    }
    
    private func sendGoalAchievementNotification(currentIntake: Double, goal: Double) {
        print("🎉 Goal achieved! Sending congratulations notification")
        print("🎉 Current intake: \(currentIntake), Goal: \(goal)")
        
        // Check if we already sent a goal notification today to avoid spam
        let defaults = UserDefaults.standard
        let today = Calendar.current.startOfDay(for: Date())
        let lastGoalNotificationDate = defaults.object(forKey: "lastGoalNotificationDate") as? Date
        
        print("🎉 Today: \(today)")
        print("🎉 Last goal notification date: \(lastGoalNotificationDate?.description ?? "nil")")
        
        if let lastDate = lastGoalNotificationDate,
           Calendar.current.isDate(lastDate, inSameDayAs: today) {
            print("📅 Goal notification already sent today, skipping")
            return
        }
        
        print("🎉 Proceeding with congratulations notification...")
        
        // Create congratulations notification content
        let content = UNMutableNotificationContent()
        content.title = "🎉 Congratulations!"
        content.body = "Amazing! You've reached your daily water goal of \(Int(goal)) cups! Keep up the great work! 💧"
        content.sound = .default
        content.badge = NSNumber(value: 1) // Keep badge for goal achievement - it's special!
        
        // Add some celebratory emojis to make it feel special
        let celebrationMessages = [
            "🎉 Fantastic! You've hit your water goal of \(Int(goal)) cups today! 💪",
            "🌟 Well done! \(Int(goal)) cups completed - you're crushing your hydration goals! 💧",
            "🏆 Goal achieved! \(Int(goal)) cups down - your body thanks you! ✨",
            "🎊 Awesome! You've reached \(Int(goal)) cups today. Stay hydrated, stay healthy! 🌊",
            "💪 Great job! Daily water goal of \(Int(goal)) cups complete! Keep it up! 🎯"
        ]
        
        content.body = celebrationMessages.randomElement() ?? content.body
        
        // Send immediately
        let request = UNNotificationRequest(
            identifier: "goal-achievement-\(Date().timeIntervalSince1970)",
            content: content,
            trigger: nil // Send immediately
        )
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("❌ Failed to send goal achievement notification: \(error.localizedDescription)")
            } else {
                print("✅ Goal achievement notification sent successfully!")
                // Record that we sent a goal notification today
                defaults.set(today, forKey: "lastGoalNotificationDate")
            }
        }
    }
    
    // MARK: - Progress Tracking
    private func getProgressInfo() -> (current: Double, goal: Double, percentage: Int) {
        guard let manager = waterReminderManager else {
            return (0, 8, 0) // Default values
        }
        
        let current = manager.currentWaterIntake
        let goal = manager.waterIntakeGoal
        let percentage = Int((current / goal) * 100)
        
        return (current, goal, percentage)
    }
    
    private func createDynamicNotificationContent() -> UNMutableNotificationContent {
        let content = UNMutableNotificationContent()
        
        // Get real-time progress from UserDefaults (updated by notification actions)
        let progress = getProgressInfoFromUserDefaults()
        
        content.title = "Time to Hydrate! 💧"
        content.body = "Progress: \(Int(progress.current))/\(Int(progress.goal)) cups (\(progress.percentage)%)"
        content.sound = .default
        content.categoryIdentifier = "WATER_REMINDER"
        // Badge removed - will be cleared when app opens
        
        print("🔔 Created dynamic notification content with progress: \(Int(progress.current))/\(Int(progress.goal)) cups (\(progress.percentage)%)")
        
        return content
    }
    
    private func getProgressInfoFromUserDefaults() -> (current: Double, goal: Double, percentage: Int) {
        let defaults = UserDefaults.standard
        
        // Get current progress from UserDefaults (reset logic is handled by app, not notifications)
        let current = defaults.double(forKey: "currentWaterIntake")
        let goal = defaults.double(forKey: "waterIntakeGoal")
        
        let percentage = goal > 0 ? Int((current / goal) * 100) : 0
        
        print("📊 Notification progress - Current: \(current), Goal: \(goal), Percentage: \(percentage)%")
        
        return (current, goal, percentage)
    }
    
    private func shouldResetDailyIntakeForNotifications() -> Bool {
        let defaults = UserDefaults.standard
        let currentIntake = defaults.double(forKey: "currentWaterIntake")
        
        // If there's no water intake recorded, don't reset
        if currentIntake == 0 {
            return false
        }
        
        // Check if we have a lastDrinkTime
        guard let lastDrinkData = defaults.data(forKey: "lastDrinkTime"),
              let lastDrinkTime = try? JSONDecoder().decode(Date.self, from: lastDrinkData) else {
            return false
        }
        
        let calendar = Calendar.current
        let isNewDay = !calendar.isDate(lastDrinkTime, inSameDayAs: Date())
        
        print("🔍 Notification reset check - Last drink: \(lastDrinkTime), Is new day: \(isNewDay)")
        
        return isNewDay
    }
    
    func cancelRemainingNotificationsForToday() {
        print("🚫 Canceling all remaining notifications for today...")
        
        UNUserNotificationCenter.current().getPendingNotificationRequests { requests in
            let todayNotifications = requests.filter { $0.identifier.hasPrefix("water-reminder-") && !$0.identifier.hasPrefix("water-reminder-tomorrow-") }
            
            for notification in todayNotifications {
                UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [notification.identifier])
                print("🚫 Canceled today's notification: \(notification.identifier)")
            }
            
            print("🎯 Canceled \(todayNotifications.count) remaining notifications for today")
        }
    }
    
    func updateAllPendingNotifications() {
        print("🔄 Updating all pending notifications with new progress...")
        
        UNUserNotificationCenter.current().getPendingNotificationRequests { requests in
            let recurringNotifications = requests.filter { $0.identifier.hasPrefix("water-reminder-") && !$0.identifier.hasPrefix("water-reminder-tomorrow-") }
            
            for notification in recurringNotifications {
                // Cancel the old notification
                UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [notification.identifier])
                
                // Create new content with updated progress
                let newContent = self.createDynamicNotificationContent()
                
                // Recreate the notification with the same trigger but updated content
                if let trigger = notification.trigger as? UNCalendarNotificationTrigger {
                    let newRequest = UNNotificationRequest(
                        identifier: notification.identifier,
                        content: newContent,
                        trigger: trigger
                    )
                    
                    UNUserNotificationCenter.current().add(newRequest) { error in
                        if let error = error {
                            print("❌ Error updating notification \(notification.identifier): \(error)")
                        } else {
                            print("✅ Updated notification \(notification.identifier) with new progress")
                        }
                    }
                }
            }
        }
    }
    
    private func scheduleTomorrowNotification(at date: Date) {
        // Create notification content for new day (no progress, no actions)
        let content = createNewDayNotificationContent()
        
        // Use timezone-aware date components with local timezone
        let calendar = Calendar.current
        let localTimeZone = TimeZone.current
        var triggerDate = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: date)
        triggerDate.timeZone = localTimeZone
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: triggerDate, repeats: false)
        
        let identifier = "water-reminder-tomorrow-\(Int(date.timeIntervalSince1970))"
        let request = UNNotificationRequest(
            identifier: identifier,
            content: content,
            trigger: trigger
        )
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("❌ Error scheduling tomorrow notification for \(date): \(error)")
            } else {
                let formatter = DateFormatter()
                formatter.timeZone = localTimeZone
                formatter.dateStyle = .none
                formatter.timeStyle = .short
                let localTime = formatter.string(from: date)
                print("✅ Scheduled tomorrow notification (new day message) for \(localTime) local time")
            }
        }
    }
    
    private func createNotificationContentWithProgress(current: Double, goal: Double) -> UNMutableNotificationContent {
        let content = UNMutableNotificationContent()
        content.title = "Time to Hydrate! 💧"
        
        // Calculate percentage
        let percentage = goal > 0 ? Int((current / goal) * 100) : 0
        content.body = "Progress: \(Int(current))/\(Int(goal)) cups (\(percentage)%)"
        
        content.sound = .default
        content.categoryIdentifier = "WATER_REMINDER"
        
        print("🔔 Created notification content with progress: \(Int(current))/\(Int(goal)) cups (\(percentage)%)")
        
        return content
    }
    
    // New function to create notification content for new day (no progress, no actions)
    private func createNewDayNotificationContent() -> UNMutableNotificationContent {
        let content = UNMutableNotificationContent()
        content.title = "Good Morning! ☀️"
        content.body = "Tap to start a new day of hydration!"
        content.sound = .default
        // No categoryIdentifier = no custom actions, just default tap
        print("🔔 Created new day notification content")
        return content
    }
    
    func scheduleWaterReminder(at date: Date) {
        let content = createDynamicNotificationContent()
        
        // Use timezone-aware date components with local timezone
        let calendar = Calendar.current
        let localTimeZone = TimeZone.current
        var triggerDate = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: date)
        triggerDate.timeZone = localTimeZone
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: triggerDate, repeats: false)
        
        let identifier = "water-reminder-\(Int(date.timeIntervalSince1970))"
        let request = UNNotificationRequest(
            identifier: identifier,
            content: content,
            trigger: trigger
        )
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("❌ Error scheduling notification for \(date): \(error)")
            } else {
                let formatter = DateFormatter()
                formatter.timeZone = localTimeZone
                formatter.dateStyle = .none
                formatter.timeStyle = .short
                let localTime = formatter.string(from: date)
                print("✅ Scheduled notification for \(localTime) local time")
                
                // Verify the notification was actually scheduled immediately
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    self.verifyNotificationScheduled(identifier: identifier)
                }
                
                // Also verify after 2 seconds to see if it disappears
                DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                    self.verifyNotificationScheduled(identifier: identifier)
                }
            }
        }
    }
    
    func scheduleRecurringWaterReminders(startTime: Date, endTime: Date, interval: TimeInterval) {
        print("🔄 SCHEDULING RECURRING DAILY REMINDERS")
        
        // Cancel existing notifications first
        cancelAllNotifications()
        
        let calendar = Calendar.current
        let localTimeZone = TimeZone.current
        
        // Extract hour and minute from start and end times
        let startHour = calendar.component(.hour, from: startTime)
        let startMinute = calendar.component(.minute, from: startTime)
        let endHour = calendar.component(.hour, from: endTime)
        let endMinute = calendar.component(.minute, from: endTime)
        
        // Calculate how many notifications per day
        let startMinutes = startHour * 60 + startMinute
        let endMinutes = endHour * 60 + endMinute
        let intervalMinutes = Int(interval / 60)
        
        print("🔍 DEBUG: Interval calculation - Input: \(interval) seconds, Calculated: \(intervalMinutes) minutes")
        
        guard intervalMinutes > 0 else {
            print("❌ Invalid interval: \(interval) seconds")
            return
        }
        
        let notificationsPerDay = (endMinutes - startMinutes) / intervalMinutes + 1
        
        print("📅 Scheduling \(notificationsPerDay) notifications per day")
        print("⏰ From \(startHour):\(String(format: "%02d", startMinute)) to \(endHour):\(String(format: "%02d", endMinute))")
        print("🔄 Every \(intervalMinutes) minutes")
        
        // Schedule recurring notifications for each time slot
        for notificationIndex in 0..<notificationsPerDay {
            let minutesFromStart = notificationIndex * intervalMinutes
            let totalMinutes = startMinutes + minutesFromStart
            
            // Skip if this time is after end time
            if totalMinutes > endMinutes {
                break
            }
            
            let hour = totalMinutes / 60
            let minute = totalMinutes % 60
            
            // Create date components for this time (every day)
            var dateComponents = DateComponents()
            dateComponents.hour = hour
            dateComponents.minute = minute
            dateComponents.timeZone = localTimeZone
            
            // Create the trigger that repeats daily
            let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
            
            // Create unique identifier for this recurring notification
            let identifier = "recurring-water-reminder-\(hour)-\(minute)"
            
            // Create content that will be updated when notification fires
            let content = self.createDynamicNotificationContent()
            
            let request = UNNotificationRequest(
                identifier: identifier,
                content: content,
                trigger: trigger
            )
            
            UNUserNotificationCenter.current().add(request) { error in
                if let error = error {
                    print("❌ Error scheduling recurring notification for \(hour):\(String(format: "%02d", minute)): \(error)")
                } else {
                    print("✅ Scheduled recurring notification for \(hour):\(String(format: "%02d", minute)) daily")
                }
            }
        }
        
        // Verify what was scheduled
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            self.debugNotificationStatus()
        }
    }
    
    func hasRecurringNotifications() -> Bool {
        var hasRecurring = false
        let semaphore = DispatchSemaphore(value: 0)
        
        UNUserNotificationCenter.current().getPendingNotificationRequests { requests in
            hasRecurring = requests.contains { request in
                request.identifier.hasPrefix("recurring-water-reminder-") ||
                request.identifier.hasPrefix("water-reminder-")
            }
            semaphore.signal()
        }
        
        semaphore.wait()
        return hasRecurring
    }
    
    // MARK: - Async version for better UI performance
    func hasRecurringNotificationsAsync(completion: @escaping (Bool) -> Void) {
        UNUserNotificationCenter.current().getPendingNotificationRequests { requests in
            let hasRecurring = requests.contains { request in
                request.identifier.hasPrefix("recurring-water-reminder-") ||
                request.identifier.hasPrefix("water-reminder-")
            }
            DispatchQueue.main.async {
                completion(hasRecurring)
            }
        }
    }
    
    // MARK: - Enhanced notification verification
    func verifyAndRestoreNotifications(startTime: Date, endTime: Date, interval: TimeInterval, completion: @escaping (Bool) -> Void) {
        print("🔍 VERIFYING NOTIFICATION STATUS...")
        
        UNUserNotificationCenter.current().getPendingNotificationRequests { requests in
            let recurringNotifications = requests.filter { $0.identifier.hasPrefix("recurring-water-reminder-") }
            
            print("📊 Found \(recurringNotifications.count) recurring notifications")
            
            // Check if we have the expected number of notifications
            let calendar = Calendar.current
            let startHour = calendar.component(.hour, from: startTime)
            let startMinute = calendar.component(.minute, from: startTime)
            let endHour = calendar.component(.hour, from: endTime)
            let endMinute = calendar.component(.minute, from: endTime)
            
            let startMinutes = startHour * 60 + startMinute
            let endMinutes = endHour * 60 + endMinute
            let intervalMinutes = Int(interval / 60)
            
            let expectedNotifications = intervalMinutes > 0 ? (endMinutes - startMinutes) / intervalMinutes + 1 : 0
            
            print("📅 Expected \(expectedNotifications) notifications, found \(recurringNotifications.count)")
            
            if recurringNotifications.count < expectedNotifications {
                print("⚠️ Missing notifications detected, rescheduling...")
                DispatchQueue.main.async {
                    self.scheduleRecurringWaterReminders(startTime: startTime, endTime: endTime, interval: interval)
                    completion(true)
                }
            } else {
                print("✅ All notifications are properly scheduled")
                DispatchQueue.main.async {
                    completion(true)
                }
            }
        }
    }
    
    private func checkTodayNotificationsCount() {
        UNUserNotificationCenter.current().getPendingNotificationRequests { requests in
            let todayNotifications = requests.filter { $0.identifier.hasPrefix("water-reminder-") && !$0.identifier.hasPrefix("water-reminder-tomorrow-") }
            let tomorrowNotifications = requests.filter { $0.identifier.hasPrefix("water-reminder-tomorrow-") }
            
            print("🔍 IMMEDIATE CHECK: Total: \(requests.count), Today: \(todayNotifications.count), Tomorrow: \(tomorrowNotifications.count)")
            
            if todayNotifications.count == 0 && requests.count > 0 {
                print("❌ CRITICAL: Today's notifications disappeared immediately after scheduling!")
                print("🔍 Available notifications:")
                for request in requests.prefix(5) {
                    print("  - \(request.identifier): \(request.content.title)")
                }
            }
        }
    }
    
    private func verifyNotificationScheduled(identifier: String) {
        UNUserNotificationCenter.current().getPendingNotificationRequests { requests in
            let found = requests.contains { $0.identifier == identifier }
            if found {
                print("✅ Verification: Notification '\(identifier)' is properly scheduled")
            } else {
                print("❌ Verification: Notification '\(identifier)' was NOT found in pending requests")
                print("🔍 Debug: Total pending requests: \(requests.count)")
                print("🔍 Debug: Today's notifications found: \(requests.filter { $0.identifier.hasPrefix("water-reminder-") && !$0.identifier.hasPrefix("water-reminder-tomorrow-") }.count)")
                print("🔍 Debug: Tomorrow's notifications found: \(requests.filter { $0.identifier.hasPrefix("water-reminder-tomorrow-") }.count)")
            }
        }
    }
    
    func cancelAllNotifications() {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
    }
    
    func cancelNotification(withIdentifier identifier: String) {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [identifier])
    }
    
    func getPendingNotifications(completion: @escaping ([UNNotificationRequest]) -> Void) {
        UNUserNotificationCenter.current().getPendingNotificationRequests { requests in
            completion(requests)
        }
    }
    
    func sendTestNotification() {
        // First check if we have permission
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            print("=== TEST NOTIFICATION DEBUG ===")
            print("Authorization Status: \(settings.authorizationStatus.rawValue)")
            print("Alert Setting: \(settings.alertSetting.rawValue)")
            print("Sound Setting: \(settings.soundSetting.rawValue)")
            print("Badge Setting: \(settings.badgeSetting.rawValue)")
            print("Notification Center Setting: \(settings.notificationCenterSetting.rawValue)")
            print("Lock Screen Setting: \(settings.lockScreenSetting.rawValue)")
            
            if settings.authorizationStatus == .authorized {
                // Try multiple notification methods
                self.sendImmediateNotification()
                self.sendDelayedNotification()
                self.sendCalendarNotification()
            } else {
                print("❌ Notification permission not granted.")
                print("Current status: \(settings.authorizationStatus.rawValue)")
                print("Please check iOS Settings > Notifications > Water Reminder")
                
                // Request permission if not granted
                DispatchQueue.main.async {
                    self.requestNotificationPermission()
                }
            }
            print("================================")
        }
    }
    
    
    private func sendImmediateNotification() {
        let content = UNMutableNotificationContent()
        content.title = "🚰 IMMEDIATE Test"
        content.body = "This should appear immediately!"
        content.sound = .default
        // Badge removed - will be cleared when app opens
        
        // Send immediately (no trigger)
        let request = UNNotificationRequest(
            identifier: "immediate-test-\(Date().timeIntervalSince1970)",
            content: content,
            trigger: nil
        )
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("❌ Immediate notification error: \(error)")
            } else {
                print("✅ Immediate notification sent!")
            }
        }
    }
    
    private func sendDelayedNotification() {
        let content = UNMutableNotificationContent()
        content.title = "⏰ 5-Second Test"
        content.body = "This should appear in 5 seconds!"
        content.sound = .default
        // Badge removed - will be cleared when app opens
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 5, repeats: false)
        let request = UNNotificationRequest(
            identifier: "delayed-test-\(Date().timeIntervalSince1970)",
            content: content,
            trigger: trigger
        )
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("❌ Delayed notification error: \(error)")
            } else {
                print("✅ 5-second notification scheduled!")
            }
        }
    }
    
    private func sendCalendarNotification() {
        let content = UNMutableNotificationContent()
        content.title = "📅 Calendar Test"
        content.body = "This should appear in 10 seconds!"
        content.sound = .default
        // Badge removed - will be cleared when app opens
        
        // Schedule for 10 seconds from now
        let calendar = Calendar.current
        let futureDate = calendar.date(byAdding: .second, value: 10, to: Date()) ?? Date()
        let components = calendar.dateComponents([.year, .month, .day, .hour, .minute, .second], from: futureDate)
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
        let request = UNNotificationRequest(
            identifier: "calendar-test-\(Date().timeIntervalSince1970)",
            content: content,
            trigger: trigger
        )
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("❌ Calendar notification error: \(error)")
            } else {
                print("✅ Calendar notification scheduled for \(futureDate)!")
            }
        }
    }
    
    func debugNotificationStatus() {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            print("=== NOTIFICATION DEBUG INFO ===")
            print("Authorization Status: \(settings.authorizationStatus.rawValue) (\(self.authorizationStatusString(settings.authorizationStatus)))")
            print("Alert Setting: \(settings.alertSetting.rawValue) (\(self.alertSettingString(settings.alertSetting)))")
            print("Sound Setting: \(settings.soundSetting.rawValue) (\(self.soundSettingString(settings.soundSetting)))")
            print("Badge Setting: \(settings.badgeSetting.rawValue) (\(self.badgeSettingString(settings.badgeSetting)))")
            print("Notification Center Setting: \(settings.notificationCenterSetting.rawValue) (\(self.notificationCenterSettingString(settings.notificationCenterSetting)))")
            print("Lock Screen Setting: \(settings.lockScreenSetting.rawValue) (\(self.lockScreenSettingString(settings.lockScreenSetting)))")
            print("Car Play Setting: \(settings.carPlaySetting.rawValue)")
            print("Critical Alert Setting: \(settings.criticalAlertSetting.rawValue)")
            print("Provides App Notification Settings: \(settings.providesAppNotificationSettings)")
            print("Show Previews Setting: \(settings.showPreviewsSetting.rawValue)")
            
            // Get pending notifications
            UNUserNotificationCenter.current().getPendingNotificationRequests { requests in
                print("Pending notification requests: \(requests.count)")
                
                let recurringNotifications = requests.filter { $0.identifier.hasPrefix("recurring-water-reminder-") }
                let regularNotifications = requests.filter { !$0.identifier.hasPrefix("recurring-water-reminder-") }
                
                print("🔄 Recurring notifications: \(recurringNotifications.count)")
                print("📅 Regular notifications: \(regularNotifications.count)")
                
                for request in requests.prefix(5) {
                    print("- \(request.identifier): \(request.content.title)")
                    if let trigger = request.trigger as? UNCalendarNotificationTrigger {
                        print("  Scheduled for: \(trigger.nextTriggerDate() ?? Date())")
                        print("  Repeats: \(trigger.repeats)")
                    }
                }
                
                // Check if any are due soon
                let now = Date()
                let soonNotifications = requests.filter { request in
                    if let trigger = request.trigger as? UNCalendarNotificationTrigger,
                       let nextDate = trigger.nextTriggerDate() {
                        return nextDate <= now.addingTimeInterval(300) // Within 5 minutes
                    }
                    return false
                }
                
                if !soonNotifications.isEmpty {
                    print("⚠️  \(soonNotifications.count) notifications are due within 5 minutes!")
                } else {
                    print("ℹ️  No notifications due within 5 minutes")
                }
                
                print("===============================")
            }
        }
    }
    
    // Helper functions to convert raw values to readable strings
    private func authorizationStatusString(_ status: UNAuthorizationStatus) -> String {
        switch status {
        case .notDetermined: return "Not Determined"
        case .denied: return "Denied"
        case .authorized: return "Authorized"
        case .provisional: return "Provisional"
        case .ephemeral: return "Ephemeral"
        @unknown default: return "Unknown"
        }
    }
    
    private func alertSettingString(_ setting: UNNotificationSetting) -> String {
        switch setting {
        case .notSupported: return "Not Supported"
        case .disabled: return "Disabled"
        case .enabled: return "Enabled"
        @unknown default: return "Unknown"
        }
    }
    
    private func soundSettingString(_ setting: UNNotificationSetting) -> String {
        switch setting {
        case .notSupported: return "Not Supported"
        case .disabled: return "Disabled"
        case .enabled: return "Enabled"
        @unknown default: return "Unknown"
        }
    }
    
    private func badgeSettingString(_ setting: UNNotificationSetting) -> String {
        switch setting {
        case .notSupported: return "Not Supported"
        case .disabled: return "Disabled"
        case .enabled: return "Enabled"
        @unknown default: return "Unknown"
        }
    }
    
    private func notificationCenterSettingString(_ setting: UNNotificationSetting) -> String {
        switch setting {
        case .notSupported: return "Not Supported"
        case .disabled: return "Disabled"
        case .enabled: return "Enabled"
        @unknown default: return "Unknown"
        }
    }
    
    private func lockScreenSettingString(_ setting: UNNotificationSetting) -> String {
        switch setting {
        case .notSupported: return "Not Supported"
        case .disabled: return "Disabled"
        case .enabled: return "Enabled"
        @unknown default: return "Unknown"
        }
    }
    
    
    // MARK: - UNUserNotificationCenterDelegate
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        // Show notification even when app is in foreground
        if #available(iOS 14.0, *) {
            completionHandler([.banner, .sound, .badge])
        } else {
            completionHandler([.alert, .sound, .badge])
        }
        print("Notification will present in foreground: \(notification.request.content.title)")
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        print("🔔 Notification action received: \(response.actionIdentifier)")
        
        switch response.actionIdentifier {
        case "DRINK_ONE_CUP":
            print("✅ User tapped '+1 Cup' - updating progress immediately")
            // Check if this is the first tap of the day and handle reset
            if isFirstTapOfDay() {
                print("📱 First tap of day detected from +1 action - resetting daily progress")
                openAppForFirstTapOfDay(amount: 1.0)
            } else {
                // Use the proper function that handles goal achievement notifications
                recordWaterIntakeDirectly(amount: 1.0)
                
                // Update all pending notifications with new progress
                updateAllPendingNotifications()
            }
            
        case "DRINK_TWO_CUPS":
            print("✅ User tapped '+2 Cups' - updating progress immediately")
            // Check if this is the first tap of the day and handle reset
            if isFirstTapOfDay() {
                print("📱 First tap of day detected from +2 action - resetting daily progress")
                openAppForFirstTapOfDay(amount: 2.0)
            } else {
                // Use the proper function that handles goal achievement notifications
                recordWaterIntakeDirectly(amount: 2.0)
                
                // Update all pending notifications with new progress
                updateAllPendingNotifications()
            }
            
        case "SNOOZE":
            print("⏰ User tapped 'Snooze' - rescheduling notification")
            // Reschedule notification for 15 minutes later
            let snoozeDate = Calendar.current.date(byAdding: .minute, value: 15, to: Date()) ?? Date()
            scheduleWaterReminder(at: snoozeDate)
            
        case UNNotificationDefaultActionIdentifier:
            print("📱 User tapped notification - opening app")
            // Check if this is the first tap of the day and handle accordingly
            if isFirstTapOfDay() {
                print("📱 First tap of day detected - will reset daily progress when app opens")
                // Set a flag to indicate this is the first tap of the day
                UserDefaults.standard.set(true, forKey: "isFirstTapOfDay")
                UserDefaults.standard.synchronize()
            } else {
                print("📱 Regular notification tap - no reset needed")
            }
            
        case UNNotificationDismissActionIdentifier:
            print("❌ User dismissed notification")
            
        default:
            print("Unknown action: \(response.actionIdentifier)")
        }
        
        completionHandler()
    }
} 