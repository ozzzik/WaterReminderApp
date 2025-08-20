import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var waterReminderManager: WaterReminderManager
    @EnvironmentObject var notificationManager: NotificationManager
    @Environment(\.dismiss) private var dismiss
    
    @State private var selectedIntervalIndex = 0
    @State private var customIntervalMinutes = 60
    @State private var showingCustomInterval = false
    
    private let presetIntervals = [
        (900, "15 minutes"),
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
                Section("Reminder Settings") {
                    HStack {
                        Image(systemName: "bell")
                            .foregroundColor(.blue)
                        Text("Enable Reminders")
                        Spacer()
                        Toggle("", isOn: $waterReminderManager.isReminderEnabled)
                            .labelsHidden()
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
                            if newValue < presetIntervals.count {
                                waterReminderManager.reminderInterval = TimeInterval(presetIntervals[newValue].0)
                                showingCustomInterval = false
                            } else {
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
                                            // Ensure minimum 1 minute
                                            if newValue < 1 {
                                                customIntervalMinutes = 1
                                            }
                                            updateCustomInterval()
                                        }
                                    Text("minutes")
                                }
                                
                                // Quick minute options
                                LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 4), spacing: 10) {
                                    ForEach([5, 10, 15, 20, 30, 45, 60, 90], id: \.self) { minutes in
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
                            }
                            
                            HStack {
                                Image(systemName: "sunset")
                                    .foregroundColor(.purple)
                                DatePicker("End Time", selection: $waterReminderManager.endTime, displayedComponents: .hourAndMinute)
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
                
                Section("Water Intake Goal") {
                    HStack {
                        Image(systemName: "drop.fill")
                            .foregroundColor(.blue)
                        Text("Daily Goal")
                        Spacer()
                        TextField("Cups", value: $waterReminderManager.waterIntakeGoal, format: .number)
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                            .frame(width: 80)
                        Text("cups")
                            .foregroundColor(.secondary)
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
                
                Section("About") {
                    HStack {
                        Image(systemName: "info.circle")
                            .foregroundColor(.blue)
                        Text("Version")
                        Spacer()
                        Text("1.0.0")
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
        }
        .onAppear {
            updateSelectedIntervalIndex()
        }
    }
    
    private func updateSelectedIntervalIndex() {
        let currentInterval = waterReminderManager.reminderInterval
        if let index = presetIntervals.firstIndex(where: { $0.0 == Int(currentInterval) }) {
            selectedIntervalIndex = index
            showingCustomInterval = false
        } else {
            selectedIntervalIndex = presetIntervals.count
            showingCustomInterval = true
            customIntervalMinutes = Int(currentInterval) / 60
        }
    }
    
    private func updateCustomInterval() {
        let totalSeconds = customIntervalMinutes * 60
        if totalSeconds > 0 {
            waterReminderManager.reminderInterval = TimeInterval(totalSeconds)
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