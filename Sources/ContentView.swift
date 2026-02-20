import SwiftUI

struct ContentView: View {
    @EnvironmentObject var waterReminderManager: WaterReminderManager
    @EnvironmentObject var notificationManager: NotificationManager
    @EnvironmentObject var ratingManager: RatingManager
    @EnvironmentObject var subscriptionManager: SubscriptionManager
    @EnvironmentObject var adManager: AdManager
    @State private var showingSettings = false
    @State private var showingAddWater = false
    @State private var showingNotificationSent = false
    @State private var hasRecurringNotifications = false
    @State private var showingPaywall = false
    
    // iPad-specific layout properties
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    @Environment(\.verticalSizeClass) private var verticalSizeClass
    
    private var isIPad: Bool {
        horizontalSizeClass == .regular && verticalSizeClass == .regular
    }
    
    var body: some View {
        NavigationStack {
            GeometryReader { geometry in
                ScrollView {
        if isIPad {
            // iPad: Single column layout with proper spacing
            VStack(spacing: 40) {
                // Hide upgrade banner when using ads instead of subscription
                if !SubscriptionManager.useAdsInsteadOfSubscription, subscriptionManager.hasCheckedSubscriptionStatus, !subscriptionManager.isPremiumActive {
                    UpgradeBannerView()
                        .padding(.horizontal)
                }
                
                mainContentView(maxWidth: geometry.size.width * 0.6)
                settingsContentView(maxWidth: geometry.size.width * 0.6)
            }
            .padding(.horizontal, max(60, geometry.size.width * 0.15))
                    } else {
                        // iPhone: Single column layout
                        VStack(spacing: 30) {
                            if !SubscriptionManager.useAdsInsteadOfSubscription, subscriptionManager.hasCheckedSubscriptionStatus, !subscriptionManager.isPremiumActive {
                                UpgradeBannerView()
                                    .padding(.horizontal)
                            }
                            
                            mainContentView(maxWidth: geometry.size.width)
                            settingsContentView(maxWidth: geometry.size.width)
                        }
                        .padding(.horizontal)
                    }
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        showingSettings = true
                    }) {
                        Image(systemName: "gear")
                            .foregroundColor(.blue)
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
                // Refresh subscription status when view appears to ensure banner visibility is correct
                Task {
                    await subscriptionManager.updateSubscriptionStatus()
                }
            }
            .onChange(of: waterReminderManager.isReminderEnabled) {
                updateRecurringNotificationStatus()
            }
            .onChange(of: subscriptionManager.isPremiumActive) { _, isActive in
                // Handle subscription status changes
                waterReminderManager.handleSubscriptionStatusChange()
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
    
    // MARK: - Responsive Content Views
    
    @ViewBuilder
    private func mainContentView(maxWidth: CGFloat) -> some View {
        VStack(spacing: 30) {
            // Header
            VStack(spacing: 10) {
                Text("Water Reminder")
                    .font(isIPad ? .largeTitle : .largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.blue)
                
                Text("Stay hydrated, stay healthy!")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            .padding(.top)
            
            // Water Progress Circle - Responsive sizing
            let circleSize: CGFloat = isIPad ? min(maxWidth * 0.8, 280) : 200
            let lineWidth: CGFloat = isIPad ? 24 : 20
            let fontSize: CGFloat = isIPad ? 50 : 40
            
            ZStack {
                Circle()
                    .stroke(Color.blue.opacity(0.2), lineWidth: lineWidth)
                    .frame(width: circleSize, height: circleSize)
                
                Circle()
                    .trim(from: 0, to: waterReminderManager.getProgressPercentage())
                    .stroke(
                        LinearGradient(
                            gradient: Gradient(colors: [.blue, .cyan]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        style: StrokeStyle(lineWidth: lineWidth, lineCap: .round)
                    )
                    .frame(width: circleSize, height: circleSize)
                    .rotationEffect(.degrees(-90))
                    .animation(.easeInOut(duration: 1.0), value: waterReminderManager.getProgressPercentage())
                
                VStack(spacing: 5) {
                    Text(waterReminderManager.currentWaterIntake == floor(waterReminderManager.currentWaterIntake) ? 
                         "\(Int(waterReminderManager.currentWaterIntake))" : 
                         String(format: "%.1f", waterReminderManager.currentWaterIntake))
                        .font(.system(size: fontSize, weight: .bold))
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
                
                HStack(spacing: isIPad ? 30 : 20) {
                    QuickAddButton(amount: 0.5, title: "½ Cup", subtitle: "Small")
                    QuickAddButton(amount: 1.0, title: "1 Cup", subtitle: "Standard")
                    QuickAddButton(amount: 2.0, title: "2 Cups", subtitle: "Large")
                }
            }
            
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
    
    @ViewBuilder
    private func settingsContentView(maxWidth: CGFloat) -> some View {
        VStack(spacing: 20) {
            // Reminder Status
            VStack(spacing: 15) {
                HStack {
                    // Only show active if premium AND reminders enabled
                    let isActive = waterReminderManager.isReminderEnabled && subscriptionManager.isPremiumActive
                    // Only allow toggle to be ON if premium
                    let toggleBinding = Binding(
                        get: { waterReminderManager.isReminderEnabled && subscriptionManager.isPremiumActive },
                        set: { newValue in
                            if subscriptionManager.isPremiumActive {
                                waterReminderManager.isReminderEnabled = newValue
                            }
                        }
                    )
                    
                    Image(systemName: isActive ? "bell.fill" : "bell.slash")
                        .foregroundColor(isActive ? .green : .gray)
                        .font(.title2)
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Reminders")
                            .font(.headline)
                        Text(isActive ? "Active" : subscriptionManager.isPremiumActive ? "Inactive" : "Premium Required")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                    
                    Toggle("", isOn: toggleBinding)
                        .labelsHidden()
                        .disabled(!subscriptionManager.isPremiumActive)
                }
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(12)
                
                if !subscriptionManager.isPremiumActive {
                    Text("Subscribe to enable reminder notifications")
                        .font(.caption)
                        .foregroundColor(.orange)
                        .multilineTextAlignment(.center)
                }
                
                // Setup Recurring Reminders Button
                Button(action: {
                    if subscriptionManager.isPremiumActive {
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
                .disabled(!subscriptionManager.isPremiumActive && !hasRecurringNotifications)

                // Ads: Watch ad to skip next reminder
                if SubscriptionManager.useAdsInsteadOfSubscription {
                    Button(action: {
                        guard let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene else { return }
                        adManager.showRewardedInterstitial(from: scene)
                    }) {
                        HStack {
                            Image(systemName: "play.rectangle.fill")
                            Text(adManager.isAdReady ? "Watch ad to skip next reminder" : adManager.isLoading ? "Loading ad…" : "Ad not ready")
                                .fontWeight(.medium)
                        }
                        .font(.subheadline)
                        .foregroundColor(adManager.isAdReady ? .blue : .secondary)
                    }
                    .disabled(!adManager.isAdReady)
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
                
                if waterReminderManager.isReminderEnabled && subscriptionManager.isPremiumActive {
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
    
    // iPad-specific sizing
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    @Environment(\.verticalSizeClass) private var verticalSizeClass
    
    private var isIPad: Bool {
        horizontalSizeClass == .regular && verticalSizeClass == .regular
    }
    
    private var isBlocked: Bool {
        // Block all buttons except 1 cup when not premium and not trial
        return !subscriptionManager.isPremiumActive && amount != 1.0
    }
    
    var body: some View {
        Button(action: {
            if subscriptionManager.isPremiumActive {
                waterReminderManager.recordWaterIntake(amount: amount)
            } else if amount == 1.0 {
                // Allow 1 cup even in paywall mode
                waterReminderManager.recordWaterIntake(amount: amount)
            } else {
                showingPaywall = true
            }
        }) {
            VStack(spacing: isIPad ? 8 : 5) {
                Text(title)
                    .font(isIPad ? .title3 : .headline)
                    .fontWeight(.semibold)
                    .foregroundColor(isBlocked ? .gray : .white)
                Text(subtitle)
                    .font(isIPad ? .subheadline : .caption)
                    .foregroundColor(isBlocked ? .gray.opacity(0.8) : .white.opacity(0.8))
            }
            .frame(width: isIPad ? 100 : 80, height: isIPad ? 80 : 60)
            .background(
                LinearGradient(
                    gradient: Gradient(colors: isBlocked ? [.gray.opacity(0.3), .gray.opacity(0.2)] : [.blue, .cyan]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .cornerRadius(isIPad ? 16 : 12)
            .overlay(
                // Add lock icon for blocked buttons
                isBlocked ? 
                Image(systemName: "lock.fill")
                    .foregroundColor(.gray)
                    .font(isIPad ? .title3 : .caption)
                : nil
            )
        }
        .disabled(isBlocked)
        .sheet(isPresented: $showingPaywall) {
            PaywallView()
                .environmentObject(subscriptionManager)
        }
    }
}


#Preview {
    ContentView()
        .environmentObject(WaterReminderManager())
        .environmentObject(NotificationManager())
        .environmentObject(RatingManager())
} 

