import Foundation
import UserNotifications

class NotificationManager: NSObject, ObservableObject, UNUserNotificationCenterDelegate {
    @Published var isAuthorized = false
    
    override init() {
        super.init()
        UNUserNotificationCenter.current().delegate = self
        setupNotificationCategories()
        checkAuthorizationStatus()
    }
    
    private func setupNotificationCategories() {
        // Create notification actions
        let drinkWaterAction = UNNotificationAction(
            identifier: "DRINK_WATER",
            title: "Drink Water 💧",
            options: [.foreground]
        )
        
        let snoozeAction = UNNotificationAction(
            identifier: "SNOOZE",
            title: "Snooze 15 min ⏰",
            options: [.foreground]
        )
        
        // Create notification category
        let waterReminderCategory = UNNotificationCategory(
            identifier: "WATER_REMINDER",
            actions: [drinkWaterAction, snoozeAction],
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
    
    func scheduleWaterReminder(at date: Date) {
        let content = UNMutableNotificationContent()
        content.title = "Time to Hydrate! 💧"
        content.body = "Stay healthy and drink some water"
        content.sound = .default
        content.categoryIdentifier = "WATER_REMINDER"
        content.badge = NSNumber(value: 1)
        
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
                
                // Verify the notification was actually scheduled
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
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
            
            let content = UNMutableNotificationContent()
            content.title = "Time to Hydrate! 💧"
            content.body = "Stay healthy and drink some water"
            content.sound = .default
            content.categoryIdentifier = "WATER_REMINDER"
            content.badge = NSNumber(value: 1)
            
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
                request.identifier.hasPrefix("recurring-water-reminder-")
            }
            semaphore.signal()
        }
        
        semaphore.wait()
        return hasRecurring
    }
    
    private func verifyNotificationScheduled(identifier: String) {
        UNUserNotificationCenter.current().getPendingNotificationRequests { requests in
            let found = requests.contains { $0.identifier == identifier }
            if found {
                print("✅ Verification: Notification '\(identifier)' is properly scheduled")
            } else {
                print("❌ Verification: Notification '\(identifier)' was NOT found in pending requests")
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
        content.badge = NSNumber(value: 1)
        
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
        content.badge = NSNumber(value: 1)
        
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
        content.badge = NSNumber(value: 1)
        
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
        completionHandler([.alert, .sound, .badge])
        print("Notification will present in foreground: \(notification.request.content.title)")
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        print("Notification action received: \(response.actionIdentifier)")
        
        switch response.actionIdentifier {
        case "DRINK_WATER":
            print("✅ User tapped 'Drink Water' - recording water intake")
            // You can add logic here to record water intake
            NotificationCenter.default.post(name: NSNotification.Name("RecordWaterIntake"), object: nil)
            
        case "SNOOZE":
            print("⏰ User tapped 'Snooze' - rescheduling notification")
            // Reschedule notification for 15 minutes later
            let snoozeDate = Calendar.current.date(byAdding: .minute, value: 15, to: Date()) ?? Date()
            scheduleWaterReminder(at: snoozeDate)
            
        case UNNotificationDefaultActionIdentifier:
            print("📱 User tapped notification - opening app")
            
        case UNNotificationDismissActionIdentifier:
            print("❌ User dismissed notification")
            
        default:
            print("Unknown action: \(response.actionIdentifier)")
        }
        
        completionHandler()
    }
} 