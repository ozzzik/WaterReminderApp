import Foundation
import UserNotifications
import Combine

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
    
    init() {
        loadSettings()
        setupBindings()
        
        // If reminders were enabled, automatically set up recurring notifications
        if isReminderEnabled {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                self.scheduleReminders()
            }
        }
    }
    
    private func setupBindings() {
        $isReminderEnabled
            .sink { [weak self] enabled in
                if enabled {
                    self?.scheduleReminders()
                } else {
                    self?.cancelReminders()
                }
                self?.saveSettings()
            }
            .store(in: &cancellables)
        
        $reminderInterval
            .sink { [weak self] _ in
                if self?.isReminderEnabled == true {
                    self?.scheduleReminders()
                }
                self?.saveSettings()
            }
            .store(in: &cancellables)
        
        $startTime
            .sink { [weak self] _ in
                if self?.isReminderEnabled == true {
                    self?.scheduleReminders()
                }
                self?.saveSettings()
            }
            .store(in: &cancellables)
        
        $endTime
            .sink { [weak self] _ in
                if self?.isReminderEnabled == true {
                    self?.scheduleReminders()
                }
                self?.saveSettings()
            }
            .store(in: &cancellables)
        
        $waterIntakeGoal
            .sink { [weak self] _ in
                self?.saveSettings()
            }
            .store(in: &cancellables)
    }
    
    func scheduleReminders() {
        print("🔄 SCHEDULING RECURRING DAILY REMINDERS")
        
        // Use the new recurring notification system
        notificationManager.scheduleRecurringWaterReminders(
            startTime: startTime,
            endTime: endTime,
            interval: reminderInterval
        )
    }
    
    private func scheduleRemindersInternal() {
        // This method is no longer needed with recurring notifications
        // Keeping it for backward compatibility but it won't be called
        print("⚠️ scheduleRemindersInternal() called - this should not happen with recurring notifications")
    }
    
    func cancelReminders() {
        notificationManager.cancelAllNotifications()
    }
    
    func scheduleTestNotification() {
        print("🧪 SCHEDULING TEST NOTIFICATION FOR 30 SECONDS FROM NOW")
        let testDate = Calendar.current.date(byAdding: .second, value: 30, to: Date()) ?? Date()
        notificationManager.scheduleWaterReminder(at: testDate)
        
        // Verify it was scheduled
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.notificationManager.debugNotificationStatus()
        }
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
        currentWaterIntake += amount
        lastDrinkTime = Date()
        saveSettings()
    }
    
    func resetDailyIntake() {
        currentWaterIntake = 0.0
        lastDrinkTime = nil
        saveSettings()
    }
    
    func getProgressPercentage() -> Double {
        return min(currentWaterIntake / waterIntakeGoal, 1.0)
    }
    
    func shouldResetDailyIntake() -> Bool {
        guard let lastDrink = lastDrinkTime else { return true }
        let calendar = Calendar.current
        return !calendar.isDate(lastDrink, inSameDayAs: Date())
    }
    
    private func loadSettings() {
        let defaults = UserDefaults.standard
        isReminderEnabled = defaults.bool(forKey: "isReminderEnabled")
        reminderInterval = defaults.double(forKey: "reminderInterval")
        if reminderInterval == 0 { reminderInterval = 3600 } // Default to 1 hour
        
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
        
        currentWaterIntake = defaults.double(forKey: "currentWaterIntake")
        
        if let lastDrinkData = defaults.data(forKey: "lastDrinkTime"),
           let lastDrinkTime = try? JSONDecoder().decode(Date.self, from: lastDrinkData) {
            self.lastDrinkTime = lastDrinkTime
        }
        
        // Reset daily intake if it's a new day
        if shouldResetDailyIntake() {
            resetDailyIntake()
        }
    }
    
    private func saveSettings() {
        let defaults = UserDefaults.standard
        defaults.set(isReminderEnabled, forKey: "isReminderEnabled")
        defaults.set(reminderInterval, forKey: "reminderInterval")
        defaults.set(try? JSONEncoder().encode(startTime), forKey: "startTime")
        defaults.set(try? JSONEncoder().encode(endTime), forKey: "endTime")
        defaults.set(waterIntakeGoal, forKey: "waterIntakeGoal")
        defaults.set(currentWaterIntake, forKey: "currentWaterIntake")
        defaults.set(try? JSONEncoder().encode(lastDrinkTime), forKey: "lastDrinkTime")
    }
} 