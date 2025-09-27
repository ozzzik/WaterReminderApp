import Foundation
import UserNotifications
import Combine
import UIKit

class WaterReminderManager: ObservableObject {
    @Published var isReminderEnabled = false
    @Published var reminderInterval: TimeInterval = 3600 // 1 hour default
    @Published var startTime = Calendar.current.date(from: DateComponents(hour: 8, minute: 0)) ?? Date()
    @Published var endTime = Calendar.current.date(from: DateComponents(hour: 20, minute: 0)) ?? Date()
    @Published var waterIntakeGoal: Double = 8.0 // cups per day
    @Published var currentWaterIntake: Double = 0.0
    @Published var lastDrinkTime: Date?
    
    private let notificationManager = NotificationManager()
    private var cancellables = Set<AnyCancellable>()
    private var isInitialized = false
    private var isLoadingSettings = false
    private var dailyResetTimer: Timer?
    
    init() {
        // IMMEDIATELY load settings to override default property values
        let defaults = UserDefaults.standard
        
        // ALWAYS use UserDefaults as the source of truth - ignore any app state
        let userDefaultsIntake = defaults.double(forKey: "currentWaterIntake")
        currentWaterIntake = userDefaultsIntake
        
        // Handle version migration
        handleVersionMigration()
        
        loadSettings()
        
        // Sync with UserDefaults BEFORE setting up bindings to prevent override
        refreshWaterIntakeData()
        
        setupBindings()
        setupNotificationObservers()
        
        // Mark as initialized AFTER setting up bindings but delay to prevent immediate saves
        DispatchQueue.main.async {
            self.isInitialized = true
        }
        
        // Set the reference to WaterReminderManager in NotificationManager
        notificationManager.waterReminderManager = self
        
        // Start daily reset timer to check for new day when app is active
        startDailyResetTimer()
        
        // If reminders were enabled, verify and restore notifications
        if isReminderEnabled {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                self.verifyAndRestoreNotifications()
            }
        }
    }
    
    private func setupBindings() {
        $isReminderEnabled
            .sink { [weak self] enabled in
                print("🔔 isReminderEnabled changed to: \(enabled), isLoadingSettings: \(self?.isLoadingSettings ?? false), isInitialized: \(self?.isInitialized ?? false)")
                
                if enabled {
                    self?.scheduleReminders()
                } else {
                    self?.cancelReminders()
                }
                
                // Disabled automatic saves to prevent startup interference
                print("⏭️ Auto-save disabled for isReminderEnabled")
            }
            .store(in: &cancellables)
        
        $reminderInterval
            .sink { [weak self] newInterval in
                // Use a small delay to ensure the property is fully updated
                DispatchQueue.main.async {
                    if self?.isReminderEnabled == true {
                        self?.scheduleReminders()
                    }
                    // Disabled automatic saves to prevent startup interference
                    print("⏭️ Auto-save disabled for reminderInterval")
                }
            }
            .store(in: &cancellables)
        
        $startTime
            .sink { [weak self] _ in
                if self?.isReminderEnabled == true {
                    self?.scheduleReminders()
                }
                // Disabled automatic saves to prevent startup interference
                print("⏭️ Auto-save disabled")
            }
            .store(in: &cancellables)
        
        $endTime
            .sink { [weak self] _ in
                if self?.isReminderEnabled == true {
                    self?.scheduleReminders()
                }
                // Disabled automatic saves to prevent startup interference
                print("⏭️ Auto-save disabled")
            }
            .store(in: &cancellables)
        
        $waterIntakeGoal
            .sink { [weak self] _ in
                // Disabled automatic saves to prevent startup interference
                print("⏭️ Auto-save disabled")
            }
            .store(in: &cancellables)
    }
    
    func scheduleReminders() {
        // Use the new notification system that schedules today and tomorrow
        // The debouncing is now handled inside NotificationManager
        notificationManager.scheduleNotificationsForTodayAndTomorrow()
    }
    
    func verifyAndRestoreNotifications() {
        print("🔍 VERIFYING AND RESTORING NOTIFICATIONS ON APP LAUNCH")
        print("✅ SKIPPING: Old recurring system disabled - using new notification system")
        
        // DISABLED: Old recurring system interferes with new notification system
        // notificationManager.verifyAndRestoreNotifications(
        //     startTime: startTime,
        //     endTime: endTime,
        //     interval: reminderInterval
        // ) { [weak self] restored in
        //     if restored {
        //         print("✅ Notifications verified/restored successfully")
        //     } else {
        //         print("❌ Failed to verify/restore notifications")
        //     }
        // }
    }
    
    private func scheduleRemindersInternal() {
        // This method is no longer needed with recurring notifications
        // Keeping it for backward compatibility but it won't be called
        print("⚠️ scheduleRemindersInternal() called - this should not happen with recurring notifications")
    }
    
    func cancelReminders() {
        notificationManager.cancelAllNotifications()
    }
    
    
    func scheduleImmediateReminders() {
        print("🚨 SCHEDULING IMMEDIATE REMINDERS - BYPASSING COMPLEX LOGIC")
        
        // Clear all existing notifications
        notificationManager.cancelAllNotifications()
        
        // Wait a moment, then schedule 3 immediate notifications
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            let now = Date()
            let calendar = Calendar.current
            
            // Schedule 3 notifications: 1 min, 2 min, 3 min from now
            for i in 1...3 {
                let delay = i * 60 // i minutes in seconds
                let notificationTime = calendar.date(byAdding: .second, value: delay, to: now) ?? now
                
                print("🚨 IMMEDIATE: Scheduling notification #\(i) for \(notificationTime) (in \(i) minute(s))")
                self.notificationManager.scheduleWaterReminder(at: notificationTime)
            }
            
            // Verify what was scheduled
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                self.notificationManager.debugNotificationStatus()
            }
        }
    }
    
    func recordWaterIntake(amount: Double = 1.0) {
        let previousIntake = currentWaterIntake
        currentWaterIntake += amount
        lastDrinkTime = Date()
        saveSettings()
        
        // Check if goal was just achieved (wasn't achieved before, but is now)
        // Use exact equality to trigger exactly at the goal, not beyond
        let wasGoalAchieved = previousIntake >= waterIntakeGoal
        let isGoalNowAchieved = currentWaterIntake >= waterIntakeGoal
        
        print("🎯 Goal check - Previous: \(previousIntake), Current: \(currentWaterIntake), Goal: \(waterIntakeGoal)")
        print("🎯 Goal check - Was achieved: \(wasGoalAchieved), Is now achieved: \(isGoalNowAchieved)")
        print("🎯 Goal check - Comparison: \(currentWaterIntake) >= \(waterIntakeGoal) = \(currentWaterIntake >= waterIntakeGoal)")
        print("🎯 Goal check - Difference: \(currentWaterIntake - waterIntakeGoal)")
        
        // Send congratulations notification if goal was just achieved
        // Check for goal achievement (allowing for small floating point differences)
        if !wasGoalAchieved && isGoalNowAchieved {
            print("🎉 GOAL ACHIEVED! Sending congratulations notification")
            notificationManager.sendGoalAchievementNotificationFromApp(currentIntake: currentWaterIntake, goal: waterIntakeGoal)
            
            // Cancel all remaining notifications for today since goal is reached
            print("🎯 Goal reached! Canceling all remaining notifications for today")
            notificationManager.cancelRemainingNotificationsForToday()
        } else if wasGoalAchieved && isGoalNowAchieved {
            print("🎯 Goal was already achieved, no new congratulations notification")
        } else {
            print("🎯 Goal not yet achieved, continuing...")
        }
        
        // Refresh notifications to update progress display
        refreshNotificationContent()
    }
    
    private var refreshWorkItem: DispatchWorkItem?
    
    private func refreshNotificationContent() {
        // This will update the content of existing notifications with new progress
        if isReminderEnabled {
            // Cancel any pending refresh and start a new one
            refreshWorkItem?.cancel()
            
            let workItem = DispatchWorkItem { [weak self] in
                guard let self = self, self.isReminderEnabled else { return }
                self.scheduleReminders()
            }
            
            refreshWorkItem = workItem
            
            // Use a longer delay to allow multiple rapid presses to accumulate
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: workItem)
        }
    }
    
    func resetDailyIntake() {
        currentWaterIntake = 0.0
        lastDrinkTime = nil
        saveSettings()
        
        // Update all pending notifications with the reset progress
        notificationManager.updateAllPendingNotifications()
    }
    
    func getProgressPercentage() -> Double {
        let percentage = currentWaterIntake / waterIntakeGoal
        // Allow progress to go beyond 100% to show over-achievement
        return max(0.0, percentage)
    }
    
    func shouldResetDailyIntake() -> Bool {
        let defaults = UserDefaults.standard
        let currentIntake = defaults.double(forKey: "currentWaterIntake")
        
        // If there's no water intake recorded, don't reset (let user start fresh)
        if currentIntake == 0 {
            return false
        }
        
        // Check if we have a lastDrinkTime in UserDefaults (from notifications)
        let lastDrinkFromDefaults: Date?
        if let lastDrinkData = defaults.data(forKey: "lastDrinkTime"),
           let lastDrinkTime = try? JSONDecoder().decode(Date.self, from: lastDrinkData) {
            lastDrinkFromDefaults = lastDrinkTime
        } else {
            lastDrinkFromDefaults = nil
        }
        
        // Use the more recent lastDrinkTime (from app or UserDefaults)
        let mostRecentLastDrink = [lastDrinkTime, lastDrinkFromDefaults].compactMap { $0 }.max { $0 < $1 }
        
        guard let lastDrink = mostRecentLastDrink else { 
            // No last drink time recorded, but there's water intake - don't reset
            return false 
        }
        
        let calendar = Calendar.current
        let isNewDay = !calendar.isDate(lastDrink, inSameDayAs: Date())
        let currentDate = Date()
        
        print("🔍 Reset check - Current intake: \(currentIntake), Last drink: \(lastDrink), Is new day: \(isNewDay)")
        
        return isNewDay
    }
    
    private func loadSettings() {
        // Loading settings from UserDefaults
        isLoadingSettings = true
        
        let defaults = UserDefaults.standard
        
        // Check if isReminderEnabled has been saved before
        if defaults.object(forKey: "isReminderEnabled") != nil {
            isReminderEnabled = defaults.bool(forKey: "isReminderEnabled")
        } else {
            // First time - keep the current value (don't override)
        }
        
        let savedInterval = defaults.double(forKey: "reminderInterval")
        reminderInterval = savedInterval
        if reminderInterval == 0 { 
            reminderInterval = 3600 // Default to 1 hour
        }
        
        if let startTimeData = defaults.data(forKey: "startTime"),
           let startTime = try? JSONDecoder().decode(Date.self, from: startTimeData) {
            self.startTime = startTime
        }
        
        if let endTimeData = defaults.data(forKey: "endTime"),
           let endTime = try? JSONDecoder().decode(Date.self, from: endTimeData) {
            self.endTime = endTime
        }
        
        waterIntakeGoal = defaults.double(forKey: "waterIntakeGoal")
        if waterIntakeGoal == 0 { waterIntakeGoal = 8.0 } // Default to 8 cups
        
        // Clean up any floating-point goal values by rounding to whole numbers
        // This fixes issues with old calculated goals like 8.482315301895142
        if waterIntakeGoal != round(waterIntakeGoal) {
            let oldGoal = waterIntakeGoal
            waterIntakeGoal = round(waterIntakeGoal)
            print("🎯 Goal cleanup: \(oldGoal) -> \(waterIntakeGoal)")
            // Save the cleaned goal back to UserDefaults
            defaults.set(waterIntakeGoal, forKey: "waterIntakeGoal")
        }
        
        print("🎯 App started - Goal loaded: \(waterIntakeGoal)")
        
        currentWaterIntake = defaults.double(forKey: "currentWaterIntake")
        
        
        if let lastDrinkData = defaults.data(forKey: "lastDrinkTime"),
           let lastDrinkTime = try? JSONDecoder().decode(Date.self, from: lastDrinkData) {
            self.lastDrinkTime = lastDrinkTime
        }
        
        // Reset daily intake if it's a new day
        if shouldResetDailyIntake() {
            print("🔄 Resetting daily intake - new day detected")
            resetDailyIntake()
        } else {
            print("✅ Keeping existing daily intake - same day or no intake recorded")
        }
        
        isLoadingSettings = false
    }
    
    func saveSettingsManually() {
        // Manual save triggered by user action
        saveSettings()
    }
    
    private func saveSettings() {
        // Saving settings to UserDefaults
        
        let defaults = UserDefaults.standard
        defaults.set(isReminderEnabled, forKey: "isReminderEnabled")
        defaults.set(reminderInterval, forKey: "reminderInterval")
        defaults.set(try? JSONEncoder().encode(startTime), forKey: "startTime")
        defaults.set(try? JSONEncoder().encode(endTime), forKey: "endTime")
        defaults.set(waterIntakeGoal, forKey: "waterIntakeGoal")
        defaults.set(currentWaterIntake, forKey: "currentWaterIntake")
        defaults.set(try? JSONEncoder().encode(lastDrinkTime), forKey: "lastDrinkTime")
        defaults.synchronize()
        
        // Settings saved successfully
    }
    
    // MARK: - Public methods for better notification management
    func forceRefreshNotifications() {
        print("🔄 FORCE REFRESHING NOTIFICATIONS...")
        
        if isReminderEnabled {
            // Cancel all existing notifications first
            notificationManager.cancelAllNotifications()
            
            // Wait a moment, then reschedule
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                self.scheduleReminders()
            }
        } else {
            // Just cancel all notifications
            notificationManager.cancelAllNotifications()
        }
    }
    
    func checkNotificationStatus(completion: @escaping (Bool) -> Void) {
        notificationManager.hasRecurringNotificationsAsync { hasRecurring in
            completion(hasRecurring)
        }
    }
    
    
    // MARK: - Notification Observers
    private func setupNotificationObservers() {
        // Listen for water intake recorded from notifications
        NotificationCenter.default.addObserver(
            forName: NSNotification.Name("WaterIntakeRecorded"),
            object: nil,
            queue: .main
        ) { [weak self] notification in
            print("💧 Water intake recorded from notification - refreshing data")
            self?.refreshWaterIntakeData() // Only refresh water intake data, not all settings
        }
        
        // Listen for app becoming active to refresh data
        NotificationCenter.default.addObserver(
            forName: UIApplication.didBecomeActiveNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            print("📱 App became active - forcing complete sync with UserDefaults")
            
            // Check if this is the first tap of the day (from notification)
            let isFirstTapOfDay = UserDefaults.standard.bool(forKey: "isFirstTapOfDay")
            if isFirstTapOfDay {
                print("📱 First tap of day detected - resetting daily progress")
                self?.resetDailyIntake()
                // Clear the flag
                UserDefaults.standard.removeObject(forKey: "isFirstTapOfDay")
                UserDefaults.standard.synchronize()
            }
            
            // Note: +1/+2 notification actions now update progress immediately
            // No need to handle pendingWaterIntake flag here anymore
            
            // Check for daily reset and refresh data when app becomes active
            self?.refreshWaterIntakeData()
            self?.clearAppBadge() // Clear the red badge number
        }
    }
    
    private func refreshWaterIntakeData() {
        let defaults = UserDefaults.standard
        
        // Check if we need to reset daily intake first (before loading data)
        if shouldResetDailyIntake() {
            print("🔄 Resetting daily intake - new day detected during refresh")
            resetDailyIntake()
            return // resetDailyIntake() will call refreshWaterIntakeData() again after reset
        }
        
        // Only update water intake and last drink time - NEVER touch the goal
        let newWaterIntake = defaults.double(forKey: "currentWaterIntake")
        let newLastDrinkTime: Date?
        
        if let lastDrinkData = defaults.data(forKey: "lastDrinkTime"),
           let lastDrinkTime = try? JSONDecoder().decode(Date.self, from: lastDrinkData) {
            newLastDrinkTime = lastDrinkTime
        } else {
            newLastDrinkTime = nil
        }
        
        // Update only water intake and last drink time - keep goal unchanged
        DispatchQueue.main.async {
            // Temporarily disable bindings to prevent saveSettings() calls
            let wasLoadingSettings = self.isLoadingSettings
            self.isLoadingSettings = true
            
            // ALWAYS use UserDefaults values, never trust in-memory values after app restart
            print("🔍 REFRESH: Force updating from UserDefaults - \(self.currentWaterIntake) → \(newWaterIntake)")
            self.currentWaterIntake = newWaterIntake
            self.lastDrinkTime = newLastDrinkTime
            
            // Restore the original loading state
            self.isLoadingSettings = wasLoadingSettings
        }
        
    }
    
    private func forceCompleteSync() {
        let defaults = UserDefaults.standard
        
        print("🔄 FORCE SYNC: Reading all values from UserDefaults")
        
        // Get all values from UserDefaults
        let userDefaultsIntake = defaults.double(forKey: "currentWaterIntake")
        let userDefaultsGoal = defaults.double(forKey: "waterIntakeGoal")
        let userDefaultsEnabled = defaults.object(forKey: "isReminderEnabled") != nil ? defaults.bool(forKey: "isReminderEnabled") : true
        let userDefaultsInterval = defaults.double(forKey: "reminderInterval")
        
        print("🔍 UserDefaults values - Intake: \(userDefaultsIntake), Goal: \(userDefaultsGoal), Enabled: \(userDefaultsEnabled), Interval: \(userDefaultsInterval)")
        print("🔍 In-memory values - Intake: \(currentWaterIntake), Goal: \(waterIntakeGoal), Enabled: \(isReminderEnabled), Interval: \(reminderInterval)")
        
        // Temporarily disable bindings
        isLoadingSettings = true
        
        // Force update ALL properties to match UserDefaults exactly
        currentWaterIntake = userDefaultsIntake
        waterIntakeGoal = userDefaultsGoal > 0 ? userDefaultsGoal : 8.0
        isReminderEnabled = userDefaultsEnabled
        reminderInterval = userDefaultsInterval > 0 ? userDefaultsInterval : 3600
        
        // Handle last drink time
        if let lastDrinkData = defaults.data(forKey: "lastDrinkTime"),
           let lastDrinkTime = try? JSONDecoder().decode(Date.self, from: lastDrinkData) {
            self.lastDrinkTime = lastDrinkTime
        }
        
        // Re-enable bindings
        isLoadingSettings = false
        
        print("✅ FORCE SYNC complete - all values updated from UserDefaults")
    }
    
    // MARK: - Version Migration
    private func handleVersionMigration() {
        let defaults = UserDefaults.standard
        let currentVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.3"
        let lastVersion = defaults.string(forKey: "lastAppVersion")
        
        // First launch or version change
        if lastVersion == nil {
            performFirstLaunchSetup()
        } else if lastVersion != currentVersion {
            performVersionMigration(from: lastVersion!, to: currentVersion)
        }
        
        // Save current version
        defaults.set(currentVersion, forKey: "lastAppVersion")
        defaults.synchronize()
    }
    
    private func performFirstLaunchSetup() {
        let defaults = UserDefaults.standard
        
        // Set default values for new installations - only if they don't exist
        if defaults.object(forKey: "isReminderEnabled") == nil {
            defaults.set(true, forKey: "isReminderEnabled")
        }
        if defaults.object(forKey: "reminderInterval") == nil {
            defaults.set(3600, forKey: "reminderInterval") // 1 hour default
        }
        if defaults.object(forKey: "waterIntakeGoal") == nil {
            defaults.set(8.0, forKey: "waterIntakeGoal") // 8 cups default
        }
        
        defaults.synchronize()
    }
    
    private func performVersionMigration(from oldVersion: String, to newVersion: String) {
        let defaults = UserDefaults.standard
        // Migration from 1.1 to 1.2
        if oldVersion.hasPrefix("1.1") && newVersion.hasPrefix("1.2") {
            print("🔄 Running 1.1 → 1.2 migration")
            
            // Ensure notification categories are re-registered (for snooze fix)
            notificationManager.setupNotificationCategories()
            
            // Clear any corrupted notification state
            UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
            
            // Re-request notification permissions to ensure they're properly set up
            notificationManager.requestNotificationPermission()
            
            // Verify and fix any missing default values - but ONLY if they don't exist at all
            if defaults.object(forKey: "isReminderEnabled") == nil {
                print("🔧 Migration: Setting default isReminderEnabled")
                defaults.set(true, forKey: "isReminderEnabled")
            } else {
                print("✅ Migration: isReminderEnabled exists, not touching it")
            }
            
            if defaults.object(forKey: "waterIntakeGoal") == nil {
                print("🔧 Migration: Setting default waterIntakeGoal")
                defaults.set(8.0, forKey: "waterIntakeGoal")
            } else {
                print("✅ Migration: waterIntakeGoal exists, not touching it")
            }
            
            if defaults.object(forKey: "reminderInterval") == nil {
                print("🔧 Migration: Setting default reminderInterval")
                defaults.set(3600, forKey: "reminderInterval")
            } else {
                let existingInterval = defaults.double(forKey: "reminderInterval")
                print("✅ Migration: reminderInterval exists (\(existingInterval) sec), not touching it")
            }
            
            // Force refresh notifications with new settings after migration
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                if self.isReminderEnabled {
                    self.scheduleReminders()
                }
            }
        }
        
        // Future migrations can be added here
        if oldVersion.hasPrefix("1.2") && newVersion.hasPrefix("1.3") {
            print("🔄 Running 1.2 → 1.3 migration")
            // Version 1.3 includes notification timing fixes and fast-press improvements
            // No specific migration needed as the fixes are backward compatible
            print("✅ 1.3 migration completed - notification timing and fast-press fixes applied")
        }
        
        defaults.synchronize()
    }
    
    private func clearAppBadge() {
        DispatchQueue.main.async {
            UIApplication.shared.applicationIconBadgeNumber = 0
            print("🔴 App badge cleared")
        }
    }
    
    // MARK: - Daily Reset Timer
    private func startDailyResetTimer() {
        // Stop existing timer if any
        dailyResetTimer?.invalidate()
        
        // Create a timer that fires every minute to check for daily reset
        dailyResetTimer = Timer.scheduledTimer(withTimeInterval: 60.0, repeats: true) { [weak self] _ in
            self?.checkForDailyReset()
        }
        
        print("⏰ Daily reset timer started - checking every minute")
    }
    
    private func checkForDailyReset() {
        // Only check if app is active and we have some water intake
        guard UIApplication.shared.applicationState == .active,
              currentWaterIntake > 0 else {
            // Timer check skipped - app not active or no intake
            return
        }
        
        if shouldResetDailyIntake() {
            print("🔄 Daily reset detected while app is active - resetting intake")
            resetDailyIntake()
            
            // Update notifications for the new day
            notificationManager.updateAllPendingNotifications()
        }
    }
    
    deinit {
        dailyResetTimer?.invalidate()
        NotificationCenter.default.removeObserver(self)
    }
} 