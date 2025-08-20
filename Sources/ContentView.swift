import SwiftUI

struct ContentView: View {
    @EnvironmentObject var waterReminderManager: WaterReminderManager
    @EnvironmentObject var notificationManager: NotificationManager
    @State private var showingSettings = false
    @State private var showingAddWater = false
    @State private var showingNotificationSent = false
    @State private var hasRecurringNotifications = false
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 30) {
                // Header
                VStack(spacing: 10) {
                    Text("Water Reminder")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.blue)
                    
                    Text("Stay hydrated, stay healthy!")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .padding(.top)
                
                // Water Progress Circle
                ZStack {
                    Circle()
                        .stroke(Color.blue.opacity(0.2), lineWidth: 20)
                        .frame(width: 200, height: 200)
                    
                    Circle()
                        .trim(from: 0, to: waterReminderManager.getProgressPercentage())
                        .stroke(
                            LinearGradient(
                                gradient: Gradient(colors: [.blue, .cyan]),
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            style: StrokeStyle(lineWidth: 20, lineCap: .round)
                        )
                        .frame(width: 200, height: 200)
                        .rotationEffect(.degrees(-90))
                        .animation(.easeInOut(duration: 1.0), value: waterReminderManager.getProgressPercentage())
                    
                    VStack(spacing: 5) {
                        Text("\(Int(waterReminderManager.currentWaterIntake))")
                            .font(.system(size: 40, weight: .bold))
                            .foregroundColor(.blue)
                        
                        Text("of \(Int(waterReminderManager.waterIntakeGoal)) cups")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                
                // Quick Add Buttons
                VStack(spacing: 15) {
                    Text("Quick Add")
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    HStack(spacing: 20) {
                        QuickAddButton(amount: 0.5, title: "½ Cup", subtitle: "Small")
                        QuickAddButton(amount: 1.0, title: "1 Cup", subtitle: "Standard")
                        QuickAddButton(amount: 2.0, title: "2 Cups", subtitle: "Large")
                    }
                }
                
                // Reminder Status
                VStack(spacing: 15) {
                    HStack {
                        Image(systemName: waterReminderManager.isReminderEnabled ? "bell.fill" : "bell.slash")
                            .foregroundColor(waterReminderManager.isReminderEnabled ? .green : .red)
                        
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Reminders")
                                .font(.headline)
                            Text(waterReminderManager.isReminderEnabled ? "Active" : "Inactive")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        
                        Spacer()
                        
                        Toggle("", isOn: $waterReminderManager.isReminderEnabled)
                            .labelsHidden()
                    }
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(12)
                    
                    // Setup Recurring Reminders Button
                    Button(action: {
                        print("🔄 Setting up recurring daily reminders...")
                        waterReminderManager.scheduleReminders()
                        // Update status after scheduling
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                            updateRecurringNotificationStatus()
                        }
                    }) {
                        HStack {
                            Image(systemName: hasRecurringNotifications ? "checkmark.circle.fill" : "repeat")
                                .foregroundColor(.white)
                            Text(hasRecurringNotifications ? "Daily Reminders Active" : "Setup Daily Reminders")
                                .foregroundColor(.white)
                                .fontWeight(.medium)
                        }
                        .padding()
                        .background(hasRecurringNotifications ? Color.green : Color.blue)
                        .cornerRadius(12)
                    }
                    
                    // Notification troubleshooting info
                    if !notificationManager.isAuthorized {
                        VStack(alignment: .leading, spacing: 8) {
                            HStack {
                                Image(systemName: "exclamationmark.triangle.fill")
                                    .foregroundColor(.orange)
                                Text("Notification Issues?")
                                    .font(.headline)
                                    .foregroundColor(.orange)
                            }
                            
                            Text("1. Check iOS Settings > Notifications > Water Reminder")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            Text("2. Enable 'Allow Notifications', 'Alerts', and 'Sounds'")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            Text("3. Try the 'Test Notification' button above")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        .padding()
                        .background(Color.orange.opacity(0.1))
                        .cornerRadius(12)
                    }
                    
                    if waterReminderManager.isReminderEnabled {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Reminder Schedule")
                                .font(.subheadline)
                                .fontWeight(.medium)
                            
                            HStack {
                                Text("Every \(formatTimeInterval(waterReminderManager.reminderInterval))")
                                Spacer()
                                Text("\(formatTime(waterReminderManager.startTime)) - \(formatTime(waterReminderManager.endTime))")
                            }
                            .font(.caption)
                            .foregroundColor(.secondary)
                            
                            Text("✅ Reminders will continue automatically every day")
                                .font(.caption)
                                .foregroundColor(.green)
                        }
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(12)
                    }
                }
                
                Spacer()
                
                // Last Drink Info
                if let lastDrink = waterReminderManager.lastDrinkTime {
                    VStack(spacing: 5) {
                        Text("Last drink")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Text(timeAgoString(from: lastDrink))
                            .font(.caption)
                            .foregroundColor(.blue)
                    }
                }
            }
            }
            .padding()
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showingSettings = true }) {
                        Image(systemName: "gear")
                    }
                }
            }
            .sheet(isPresented: $showingSettings) {
                SettingsView()
                    .environmentObject(waterReminderManager)
                    .environmentObject(notificationManager)
            }
            .onAppear {
                updateRecurringNotificationStatus()
            }
            .onChange(of: waterReminderManager.isReminderEnabled) { _ in
                updateRecurringNotificationStatus()
            }
            .overlay(
                // Notification sent success message
                VStack {
                    if showingNotificationSent {
                        HStack {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(.green)
                            Text("Test notification sent!")
                                .fontWeight(.medium)
                        }
                        .padding()
                        .background(Color(.systemBackground))
                        .cornerRadius(10)
                        .shadow(radius: 5)
                        .transition(.move(edge: .top).combined(with: .opacity))
                        .animation(.easeInOut(duration: 0.3), value: showingNotificationSent)
                    }
                    Spacer()
                }
                .padding(.top, 100)
            )
        }
    }
    
    private func formatTimeInterval(_ interval: TimeInterval) -> String {
        let hours = Int(interval) / 3600
        let minutes = Int(interval) % 3600 / 60
        
        if hours > 0 {
            return "\(hours)h \(minutes)m"
        } else {
            return "\(minutes)m"
        }
    }
    
    private func formatTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
    
    private func timeAgoString(from date: Date) -> String {
        let interval = Date().timeIntervalSince(date)
        let minutes = Int(interval) / 60
        let hours = minutes / 60
        
        if hours > 0 {
            return "\(hours) hour\(hours == 1 ? "" : "s") ago"
        } else if minutes > 0 {
            return "\(minutes) minute\(minutes == 1 ? "" : "s") ago"
        } else {
            return "Just now"
        }
    }
    
    private func updateRecurringNotificationStatus() {
        hasRecurringNotifications = notificationManager.hasRecurringNotifications()
    }
}

struct QuickAddButton: View {
    @EnvironmentObject var waterReminderManager: WaterReminderManager
    let amount: Double
    let title: String
    let subtitle: String
    
    var body: some View {
        Button(action: {
            waterReminderManager.recordWaterIntake(amount: amount)
        }) {
            VStack(spacing: 5) {
                Text(title)
                    .font(.headline)
                    .foregroundColor(.white)
                Text(subtitle)
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.8))
            }
            .frame(width: 80, height: 60)
            .background(
                LinearGradient(
                    gradient: Gradient(colors: [.blue, .cyan]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .cornerRadius(12)
        }
    }
}

#Preview {
    ContentView()
        .environmentObject(WaterReminderManager())
        .environmentObject(NotificationManager())
} 

