import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var waterReminderManager: WaterReminderManager
    @EnvironmentObject var notificationManager: NotificationManager
    @EnvironmentObject var ratingManager: RatingManager
    @EnvironmentObject var subscriptionManager: SubscriptionManager
    @Environment(\.dismiss) private var dismiss
    @State private var showingPaywall = false
    
    @State private var selectedIntervalIndex = 0
    @State private var customIntervalMinutes = 60
    @State private var showingCustomInterval = false
    
    private let presetIntervals = [
        (1800, "30 minutes"),
        (2700, "45 minutes"),
        (3600, "1 hour"),
        (5400, "1.5 hours"),
        (7200, "2 hours"),
        (10800, "3 hours")
    ]
    
    var body: some View {
        NavigationView {
            Form {
                Section {
                    // Water Intake Goal - More Prominent
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Image(systemName: "target")
                                .foregroundColor(.blue)
                                .font(.title2)
                            VStack(alignment: .leading, spacing: 2) {
                                Text("Water Intake Goal")
                                    .font(.headline)
                                    .fontWeight(.semibold)
                                Text("Set your daily hydration target")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            Spacer()
                            Text(waterReminderManager.waterIntakeGoal == floor(waterReminderManager.waterIntakeGoal) ? 
                                 "\(Int(waterReminderManager.waterIntakeGoal)) cups" : 
                                 String(format: "%.1f cups", waterReminderManager.waterIntakeGoal))
                                .font(.title2)
                                .fontWeight(.bold)
                                .foregroundColor(.blue)
                        }
                        
                        // Goal Slider
                        VStack(alignment: .leading, spacing: 8) {
                            HStack {
                                Text("4 cups")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                Spacer()
                                Text("16 cups")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            
                            Slider(
                                value: $waterReminderManager.waterIntakeGoal,
                                in: 4...16,
                                step: 1
                            )
                            .accentColor(.blue)
                            .onChange(of: waterReminderManager.waterIntakeGoal) { _ in
                                waterReminderManager.saveSettingsManually()
                            }
                            
                            HStack {
                                Text("Current goal:")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                Spacer()
                                Text(waterReminderManager.waterIntakeGoal == floor(waterReminderManager.waterIntakeGoal) ? 
                                     "\(Int(waterReminderManager.waterIntakeGoal)) cups" : 
                                     String(format: "%.1f cups", waterReminderManager.waterIntakeGoal))
                                    .font(.caption)
                                    .fontWeight(.semibold)
                                    .foregroundColor(.blue)
                            }
                        }
                        
                    }
                    .padding(.vertical, 8)
                } header: {
                    Text("Water Intake Goal")
                } footer: {
                    Text("The recommended daily water intake is 8 cups (64 oz), but this can vary based on your activity level, climate, and health needs.")
                }
                
                Section("Reminder Settings") {
                    HStack {
                        Image(systemName: "bell")
                            .foregroundColor(.blue)
                        Text("Enable Reminders")
                        Spacer()
                        Toggle("", isOn: $waterReminderManager.isReminderEnabled)
                            .labelsHidden()
                            .onChange(of: waterReminderManager.isReminderEnabled) { _ in
                                waterReminderManager.saveSettingsManually()
                            }
                    }
                    
                    if !notificationManager.isAuthorized {
                        HStack {
                            Image(systemName: "exclamationmark.triangle")
                                .foregroundColor(.orange)
                            Text("Notification permissions required")
                                .foregroundColor(.orange)
                            Spacer()
                            Button("Enable") {
                                notificationManager.requestNotificationPermission()
                            }
                            .buttonStyle(.bordered)
                        }
                    }
                }
                
                if waterReminderManager.isReminderEnabled {
                    Section("Reminder Interval") {
                        Picker("Interval", selection: $selectedIntervalIndex) {
                            ForEach(0..<presetIntervals.count, id: \.self) { index in
                                Text(presetIntervals[index].1).tag(index)
                            }
                            Text("Custom").tag(presetIntervals.count)
                        }
                        .onChange(of: selectedIntervalIndex) { newValue in
                            print("🎯 User selected interval index: \(newValue)")
                            if newValue < presetIntervals.count {
                                let selectedPreset = presetIntervals[newValue]
                                print("🎯 Selected preset: \(selectedPreset.1) (\(selectedPreset.0) seconds)")
                                print("🎯 Setting reminderInterval to: \(selectedPreset.0)")
                                waterReminderManager.reminderInterval = TimeInterval(selectedPreset.0)
                                print("🎯 After setting - reminderInterval is: \(waterReminderManager.reminderInterval)")
                                showingCustomInterval = false
                                // Manual save since automatic saves are disabled
                                waterReminderManager.saveSettingsManually()
                                // Reschedule notifications with new interval
                                waterReminderManager.scheduleReminders()
                            } else {
                                print("🎯 Selected custom interval")
                                showingCustomInterval = true
                            }
                        }
                        
                        if showingCustomInterval {
                            VStack(spacing: 15) {
                                Text("Custom Interval")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                                
                                HStack {
                                    Text("Every")
                                    TextField("Minutes", value: $customIntervalMinutes, format: .number)
                                        .keyboardType(.numberPad)
                                        .textFieldStyle(.roundedBorder)
                                        .frame(width: 80)
                                        .onChange(of: customIntervalMinutes) { newValue in
                                            // Ensure minimum 30 minutes to stay within iOS 64 notification limit
                                            if newValue < 30 {
                                                customIntervalMinutes = 30
                                            }
                                            updateCustomInterval()
                                        }
                                    Text("minutes")
                                }
                                
                                // Quick minute options (minimum 30 minutes)
                                LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 4), spacing: 10) {
                                    ForEach([30, 45, 60, 90, 120, 180, 240, 300], id: \.self) { minutes in
                                        Button("\(minutes)m") {
                                            customIntervalMinutes = minutes
                                            updateCustomInterval()
                                        }
                                        .buttonStyle(.bordered)
                                        .controlSize(.small)
                                        .foregroundColor(customIntervalMinutes == minutes ? .white : .blue)
                                        .background(customIntervalMinutes == minutes ? Color.blue : Color.clear)
                                        .cornerRadius(8)
                                    }
                                }
                            }
                            .padding(.vertical, 8)
                        }
                    }
                    
                    Section("Active Hours") {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Set your daily reminder schedule")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            
                            HStack {
                                Image(systemName: "sunrise")
                                    .foregroundColor(.orange)
                                DatePicker("Start Time", selection: $waterReminderManager.startTime, displayedComponents: .hourAndMinute)
                                    .onChange(of: waterReminderManager.startTime) { _ in
                                        waterReminderManager.saveSettingsManually()
                                    }
                            }
                            
                            HStack {
                                Image(systemName: "sunset")
                                    .foregroundColor(.purple)
                                DatePicker("End Time", selection: $waterReminderManager.endTime, displayedComponents: .hourAndMinute)
                                    .onChange(of: waterReminderManager.endTime) { _ in
                                        waterReminderManager.saveSettingsManually()
                                    }
                            }
                            
                            // Quick time presets
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Quick Presets")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                
                                LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 8) {
                                    Button("Work Hours (9-17)") {
                                        setTimeRange(start: (9, 0), end: (17, 0))
                                    }
                                    .buttonStyle(.bordered)
                                    .controlSize(.small)
                                    
                                    Button("Extended (8-20)") {
                                        setTimeRange(start: (8, 0), end: (20, 0))
                                    }
                                    .buttonStyle(.bordered)
                                    .controlSize(.small)
                                    
                                    Button("Early Bird (6-18)") {
                                        setTimeRange(start: (6, 0), end: (18, 0))
                                    }
                                    .buttonStyle(.bordered)
                                    .controlSize(.small)
                                    
                                    Button("Night Owl (10-22)") {
                                        setTimeRange(start: (10, 0), end: (22, 0))
                                    }
                                    .buttonStyle(.bordered)
                                    .controlSize(.small)
                                }
                            }
                            .padding(.top, 8)
                        }
                    }
                }
                
                Section("Today's Progress") {
                    HStack {
                        Image(systemName: "chart.bar.fill")
                            .foregroundColor(.green)
                        Text("Current Intake")
                        Spacer()
                        Text("\(waterReminderManager.currentWaterIntake, specifier: "%.1f") cups")
                            .foregroundColor(.secondary)
                    }
                    
                    Button("Reset Today's Progress") {
                        waterReminderManager.resetDailyIntake()
                    }
                    .foregroundColor(.red)
                }
                
                Section("Subscription") {
                    if subscriptionManager.isPremiumActive {
                        HStack {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(.green)
                            Text("Premium Active")
                                .fontWeight(.semibold)
                            Spacer()
                        }
                    } else if subscriptionManager.isTrialActive {
                        HStack {
                            Image(systemName: "clock.fill")
                                .foregroundColor(.orange)
                            VStack(alignment: .leading) {
                                Text("Free Trial")
                                    .fontWeight(.semibold)
                                Text("\(subscriptionManager.trialDaysRemaining) days left")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            Spacer()
                        }
                    } else {
                        HStack {
                            Image(systemName: "star.fill")
                                .foregroundColor(.yellow)
                            Text("Upgrade to Premium")
                            Spacer()
                            Button("Subscribe") {
                                showingPaywall = true
                            }
                            .foregroundColor(.blue)
                        }
                    }
                }
                
                #if DEBUG
                Section("Debug Controls") {
                    HStack {
                        Button("End Trial Now") {
                            subscriptionManager.simulateTrialEnd()
                        }
                        .foregroundColor(.red)
                        
                        Spacer()
                        
                        Button("Activate Premium") {
                            subscriptionManager.simulatePremiumActivation()
                        }
                        .foregroundColor(.green)
                    }
                    
                    HStack {
                        Button("Reset Trial") {
                            subscriptionManager.resetTrial()
                        }
                        .foregroundColor(.orange)
                        
                        Spacer()
                        
                        Button("Deactivate Premium") {
                            subscriptionManager.simulatePremiumDeactivation()
                        }
                        .foregroundColor(.blue)
                    }
                    
                    Button("Clear Purchase Cache") {
                        subscriptionManager.clearRecentPurchase()
                    }
                    .foregroundColor(.purple)
                }
                #endif
                
                Section("About") {
                    HStack {
                        Image(systemName: "info.circle")
                            .foregroundColor(.blue)
                        Text("Version")
                        Spacer()
                        Text(Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.3")
                            .foregroundColor(.secondary)
                    }
                    
                    HStack {
                        Image(systemName: "heart.fill")
                            .foregroundColor(.red)
                        Text("Stay hydrated and healthy!")
                            .foregroundColor(.secondary)
                    }
                }
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
            .sheet(isPresented: $showingPaywall) {
                PaywallView()
                    .environmentObject(subscriptionManager)
            }
        }
        .onAppear {
            updateSelectedIntervalIndex()
        }
    }
    
    private func updateSelectedIntervalIndex() {
        let currentInterval = waterReminderManager.reminderInterval
        print("🔍 UpdateSelectedIntervalIndex - currentInterval: \(currentInterval) seconds")
        print("🔍 Converting to Int: \(Int(currentInterval))")
        
        if let index = presetIntervals.firstIndex(where: { $0.0 == Int(currentInterval) }) {
            print("✅ Found matching preset at index \(index): \(presetIntervals[index])")
            selectedIntervalIndex = index
            showingCustomInterval = false
        } else {
            print("❌ No matching preset found, using custom")
            print("🔍 Available presets: \(presetIntervals.map { $0.0 })")
            selectedIntervalIndex = presetIntervals.count
            showingCustomInterval = true
            customIntervalMinutes = Int(currentInterval) / 60
        }
    }
    
    private func updateCustomInterval() {
        let totalSeconds = customIntervalMinutes * 60
        if totalSeconds > 0 {
            waterReminderManager.reminderInterval = TimeInterval(totalSeconds)
            waterReminderManager.saveSettingsManually()
            // Reschedule notifications with new interval
            waterReminderManager.scheduleReminders()
        }
    }
    
    private func setTimeRange(start: (hour: Int, minute: Int), end: (hour: Int, minute: Int)) {
        let calendar = Calendar.current
        
        // Set start time
        var startComponents = DateComponents()
        startComponents.hour = start.hour
        startComponents.minute = start.minute
        if let startTime = calendar.date(from: startComponents) {
            waterReminderManager.startTime = startTime
        }
        
        // Set end time
        var endComponents = DateComponents()
        endComponents.hour = end.hour
        endComponents.minute = end.minute
        if let endTime = calendar.date(from: endComponents) {
            waterReminderManager.endTime = endTime
        }
    }
}


#Preview {
    SettingsView()
        .environmentObject(WaterReminderManager())
        .environmentObject(NotificationManager())
} 