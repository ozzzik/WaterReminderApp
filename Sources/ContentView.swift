import SwiftUI

struct ContentView: View {
    @EnvironmentObject var waterReminderManager: WaterReminderManager
    @EnvironmentObject var notificationManager: NotificationManager
    @EnvironmentObject var ratingManager: RatingManager
    @EnvironmentObject var subscriptionManager: SubscriptionManager
    @State private var showingSettings = false
    @State private var showingAddWater = false
    @State private var showingNotificationSent = false
    @State private var hasRecurringNotifications = false
    @State private var showingPaywall = false
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 30) {
                // Trial Banner
                if subscriptionManager.isTrialActive {
                    TrialBannerView()
                        .padding(.horizontal)
                }
                
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
                        Text(waterReminderManager.currentWaterIntake == floor(waterReminderManager.currentWaterIntake) ? 
                             "\(Int(waterReminderManager.currentWaterIntake))" : 
                             String(format: "%.1f", waterReminderManager.currentWaterIntake))
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
                        Image(systemName: waterReminderManager.isReminderEnabled && (subscriptionManager.isPremiumActive || subscriptionManager.isTrialActive) ? "bell.fill" : "bell.slash")
                            .foregroundColor(waterReminderManager.isReminderEnabled && (subscriptionManager.isPremiumActive || subscriptionManager.isTrialActive) ? .green : .red)
                        
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Reminders")
                                .font(.headline)
                            Text(waterReminderManager.isReminderEnabled && (subscriptionManager.isPremiumActive || subscriptionManager.isTrialActive) ? "Active" : "Inactive")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        
                        Spacer()
                        
                        Toggle("", isOn: $waterReminderManager.isReminderEnabled)
                            .labelsHidden()
                            .disabled(!subscriptionManager.isPremiumActive && !subscriptionManager.isTrialActive)
                    }
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(12)
                    
                    // Setup Recurring Reminders Button
                    Button(action: {
                        if subscriptionManager.isPremiumActive || subscriptionManager.isTrialActive {
                            print("🔄 Setting up recurring daily reminders...")
                            waterReminderManager.scheduleReminders()
                            // Update status after scheduling
                            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                                updateRecurringNotificationStatus()
                            }
                        } else {
                            showingPaywall = true
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
                    .disabled(!subscriptionManager.isPremiumActive && !subscriptionManager.isTrialActive && !hasRecurringNotifications)
                    
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
                    
                    if waterReminderManager.isReminderEnabled && (subscriptionManager.isPremiumActive || subscriptionManager.isTrialActive) {
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
                    Button(action: { 
                        if subscriptionManager.isPremiumActive || subscriptionManager.isTrialActive {
                            showingSettings = true 
                        } else {
                            showingPaywall = true
                        }
                    }) {
                        Image(systemName: "gear")
                            .foregroundColor((subscriptionManager.isPremiumActive || subscriptionManager.isTrialActive) ? .blue : .gray)
                    }
                }
            }
            .sheet(isPresented: $showingSettings) {
                SettingsView()
                    .environmentObject(waterReminderManager)
                    .environmentObject(notificationManager)
            }
            .sheet(isPresented: $showingPaywall) {
                PaywallView()
                    .environmentObject(subscriptionManager)
            }
            .onAppear {
                updateRecurringNotificationStatus()
                setupNotificationObservers()
            }
            .onChange(of: waterReminderManager.isReminderEnabled) {
                updateRecurringNotificationStatus()
            }
            .overlay(
                // Rating request overlay
                ZStack {
                    if ratingManager.shouldShowRatingRequest {
                        Color.black.opacity(0.4)
                            .ignoresSafeArea()
                            .onTapGesture {
                                ratingManager.userDeclinedRating()
                            }
                        
                        RatingRequestView(ratingManager: ratingManager)
                            .transition(.scale.combined(with: .opacity))
                            .animation(.spring(response: 0.5, dampingFraction: 0.8), value: ratingManager.shouldShowRatingRequest)
                    }
                }
            )
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
        notificationManager.hasRecurringNotificationsAsync { hasRecurring in
            hasRecurringNotifications = hasRecurring
        }
    }
    
    private func setupNotificationObservers() {
        // Listen for water intake recorded from notifications
        NotificationCenter.default.addObserver(
            forName: NSNotification.Name("WaterIntakeRecorded"),
            object: nil,
            queue: .main
        ) { notification in
            print("💧 Water intake recorded from notification")
            // The UI will automatically update due to @Published properties
        }
    }
}

struct QuickAddButton: View {
    @EnvironmentObject var waterReminderManager: WaterReminderManager
    @EnvironmentObject var subscriptionManager: SubscriptionManager
    let amount: Double
    let title: String
    let subtitle: String
    @State private var showingPaywall = false
    
    private var isBlocked: Bool {
        // Block all buttons except 1 cup when not premium and not trial
        return !subscriptionManager.isPremiumActive && !subscriptionManager.isTrialActive && amount != 1.0
    }
    
    var body: some View {
        Button(action: {
            if subscriptionManager.isPremiumActive || subscriptionManager.isTrialActive {
                waterReminderManager.recordWaterIntake(amount: amount)
            } else if amount == 1.0 {
                // Allow 1 cup even in paywall mode
                waterReminderManager.recordWaterIntake(amount: amount)
            } else {
                showingPaywall = true
            }
        }) {
            VStack(spacing: 5) {
                Text(title)
                    .font(.headline)
                    .foregroundColor(isBlocked ? .gray : .white)
                Text(subtitle)
                    .font(.caption)
                    .foregroundColor(isBlocked ? .gray.opacity(0.8) : .white.opacity(0.8))
            }
            .frame(width: 80, height: 60)
            .background(
                LinearGradient(
                    gradient: Gradient(colors: isBlocked ? [.gray.opacity(0.3), .gray.opacity(0.2)] : [.blue, .cyan]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .cornerRadius(12)
            .overlay(
                // Add lock icon for blocked buttons
                isBlocked ? 
                Image(systemName: "lock.fill")
                    .foregroundColor(.gray)
                    .font(.caption)
                : nil
            )
        }
        .disabled(isBlocked)
        .sheet(isPresented: $showingPaywall) {
            PaywallView()
        }
    }
}


#Preview {
    ContentView()
        .environmentObject(WaterReminderManager())
        .environmentObject(NotificationManager())
        .environmentObject(RatingManager())
} 

