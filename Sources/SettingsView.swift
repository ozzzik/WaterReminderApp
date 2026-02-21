import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var waterReminderManager: WaterReminderManager
    @EnvironmentObject var notificationManager: NotificationManager
    @EnvironmentObject var ratingManager: RatingManager
    @EnvironmentObject var subscriptionManager: SubscriptionManager
    @EnvironmentObject var adManager: AdManager
    @Environment(\.dismiss) private var dismiss
    @State private var showingPaywall = false
    
    @State private var selectedIntervalIndex = 0
    @State private var customIntervalMinutes = 60
    @State private var showingCustomInterval = false
    
    // iPad-specific layout properties
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    @Environment(\.verticalSizeClass) private var verticalSizeClass
    
    private var isIPad: Bool {
        horizontalSizeClass == .regular && verticalSizeClass == .regular
    }
    
    private let presetIntervals = [
        (1800, "30 minutes"),
        (2700, "45 minutes"),
        (3600, "1 hour"),
        (5400, "1.5 hours"),
        (7200, "2 hours"),
        (10800, "3 hours")
    ]
    
    var body: some View {
        NavigationStack {
            if isIPad {
                // iPad: Use ScrollView with proper spacing instead of Form
                ScrollView {
                    LazyVStack(spacing: 24) {
                        // Water Intake Goal Section
                        WaterIntakeGoalSection()
                        
                        // Reminder Settings Section
                        ReminderSettingsSection(
                            selectedIntervalIndex: $selectedIntervalIndex,
                            customIntervalMinutes: $customIntervalMinutes,
                            showingCustomInterval: $showingCustomInterval,
                            presetIntervals: presetIntervals
                        )
                        
                        if SubscriptionManager.useAdsInsteadOfSubscription, !adManager.isAdFreeForRestOfDay {
                            AdRewardSection()
                        } else if !SubscriptionManager.useAdsInsteadOfSubscription {
                            SubscriptionSection(showingPaywall: $showingPaywall)
                        }
                        
                        #if DEBUG
                        // Debug Controls
                        DebugControlsSection()
                        #endif
                        
                        // About Section
                        AboutSection()
                    }
                    .padding(.horizontal, 40)
                    .padding(.vertical, 20)
                }
            } else {
                // iPhone: Use Form for better native feel
                Form {
                // Water Intake Goal Section
                WaterIntakeGoalSection()
                
                // Reminder Settings Section
                ReminderSettingsSection(
                    selectedIntervalIndex: $selectedIntervalIndex,
                    customIntervalMinutes: $customIntervalMinutes,
                    showingCustomInterval: $showingCustomInterval,
                    presetIntervals: presetIntervals
                )
                
                if SubscriptionManager.useAdsInsteadOfSubscription, !adManager.isAdFreeForRestOfDay {
                    AdRewardSection()
                } else if !SubscriptionManager.useAdsInsteadOfSubscription {
                    SubscriptionSection(showingPaywall: $showingPaywall)
                }
                
                #if DEBUG
                // Debug Controls
                DebugControlsSection()
                #endif
                
                        // About Section
                        AboutSection()
                    }
                }
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
            .sheet(isPresented: $showingPaywall) {
                PaywallView()
                    .environmentObject(subscriptionManager)
            }
            .onAppear {
                // Initialize selected interval index
                if let index = presetIntervals.firstIndex(where: { $0.0 == Int(waterReminderManager.reminderInterval) }) {
                    selectedIntervalIndex = index
                }
            }
        }
    }

// MARK: - Water Intake Goal Section

struct WaterIntakeGoalSection: View {
    @EnvironmentObject var waterReminderManager: WaterReminderManager
    
    // iPad-specific layout properties
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    @Environment(\.verticalSizeClass) private var verticalSizeClass
    
    private var isIPad: Bool {
        horizontalSizeClass == .regular && verticalSizeClass == .regular
    }
    
    var body: some View {
        if isIPad {
            // iPad: Custom section layout
            VStack(alignment: .leading, spacing: 16) {
                HStack {
                    Image(systemName: "target")
                        .foregroundColor(.blue)
                        .font(.title2)
                    Text("Water Intake Goal")
                        .font(.title2)
                        .fontWeight(.semibold)
                    Spacer()
                }
                
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
                        Text(goalDisplayText)
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
                        .onChange(of: waterReminderManager.waterIntakeGoal) { _, _ in
                            waterReminderManager.saveSettingsManually()
                        }
                        
                        HStack {
                            Text("Current goal:")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            Spacer()
                            Text(goalDisplayText)
                                .font(.caption)
                                .fontWeight(.semibold)
                                .foregroundColor(.blue)
                        }
                    }
                }
                .padding(20)
                .background(Color(.systemGray6))
                .cornerRadius(12)
                
                Text("The recommended daily water intake is 8 cups (64 oz), but this can vary based on your activity level, climate, and health needs.")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .padding(.horizontal, 4)
            }
        } else {
            // iPhone: Use Section
            Section {
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
                        Text(goalDisplayText)
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
                        .onChange(of: waterReminderManager.waterIntakeGoal) { _, _ in
                            waterReminderManager.saveSettingsManually()
                        }
                        
                        HStack {
                            Text("Current goal:")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            Spacer()
                            Text(goalDisplayText)
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
        }
    }
    
    private var goalDisplayText: String {
        if waterReminderManager.waterIntakeGoal == floor(waterReminderManager.waterIntakeGoal) {
            return "\(Int(waterReminderManager.waterIntakeGoal)) cups"
        } else {
            return String(format: "%.1f cups", waterReminderManager.waterIntakeGoal)
        }
    }
}

// MARK: - Reminder Settings Section

struct ReminderSettingsSection: View {
    @EnvironmentObject var waterReminderManager: WaterReminderManager
    @EnvironmentObject var notificationManager: NotificationManager
    
    @Binding var selectedIntervalIndex: Int
    @Binding var customIntervalMinutes: Int
    @Binding var showingCustomInterval: Bool
    let presetIntervals: [(Int, String)]
    
    var body: some View {
        Section("Reminder Settings") {
            HStack {
                Image(systemName: "bell")
                    .foregroundColor(.blue)
                Text("Enable Reminders")
                Spacer()
                Toggle("", isOn: $waterReminderManager.isReminderEnabled)
                    .labelsHidden()
                    .onChange(of: waterReminderManager.isReminderEnabled) { _, _ in
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
                .onChange(of: selectedIntervalIndex) { _, newValue in
                    if newValue < presetIntervals.count {
                        let selectedPreset = presetIntervals[newValue]
                        waterReminderManager.reminderInterval = TimeInterval(selectedPreset.0)
                        showingCustomInterval = false
                        waterReminderManager.saveSettingsManually()
                        waterReminderManager.scheduleReminders()
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
                                .onChange(of: customIntervalMinutes) { _, newValue in
                                    if newValue < 30 {
                                        customIntervalMinutes = 30
                                    }
                                    updateCustomInterval()
                                }
                            Text("minutes")
                        }
                    }
                }
            }
        }
    }
    
    private func updateCustomInterval() {
        let intervalSeconds = TimeInterval(customIntervalMinutes * 60)
        waterReminderManager.reminderInterval = intervalSeconds
        waterReminderManager.saveSettingsManually()
        waterReminderManager.scheduleReminders()
    }
}

// MARK: - Ad Reward Section (when using ads instead of subscription)

struct AdRewardSection: View {
    @EnvironmentObject var adManager: AdManager

    var body: some View {
        Section("Ad-free for today") {
            Button(action: {
                if adManager.isAdReady {
                    let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene
                    adManager.showRewardedInterstitial(from: scene)
                } else {
                    Task { await adManager.loadRewardedInterstitial() }
                }
            }) {
                HStack {
                    Image(systemName: "play.rectangle.fill")
                        .foregroundColor(.blue)
                    Text(adManager.isAdReady ? "Watch ad for ad-free rest of day" : adManager.isLoading ? "Loading ad…" : "Tap to load ad")
                        .foregroundColor(adManager.isAdReady ? .primary : .secondary)
                }
            }
        }
    }
}

// MARK: - Subscription Section

struct SubscriptionSection: View {
    @EnvironmentObject var subscriptionManager: SubscriptionManager
    @Binding var showingPaywall: Bool
    
    var body: some View {
        Section("Subscription") {
            if subscriptionManager.isPremiumActive && subscriptionManager.subscriptionStatus == .subscribed {
                HStack {
                    Image(systemName: "checkmark.seal.fill")
                        .foregroundColor(.green)
                    Text("Premium Active")
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
    }
}

// MARK: - Debug Controls Section

#if DEBUG
struct DebugControlsSection: View {
    @EnvironmentObject var subscriptionManager: SubscriptionManager
    @EnvironmentObject var waterReminderManager: WaterReminderManager
    
    var body: some View {
        Section("Debug Controls") {
            Text("Testing Tools (Xcode Only)")
                .font(.caption)
                .foregroundColor(.secondary)
            
            Button("Reset cups") {
                waterReminderManager.resetDailyIntake()
            }
            .buttonStyle(.bordered)
            .tint(.orange)
            .controlSize(.small)
            
            HStack(spacing: 12) {
                Button("Activate Premium") {
                    subscriptionManager.activateSubscription()
                }
                .buttonStyle(.borderedProminent)
                .tint(.green)
                .controlSize(.small)
                
                Button("Cancel Subscription") {
                    subscriptionManager.cancelSubscription()
                }
                .buttonStyle(.borderedProminent)
                .tint(.red)
                .controlSize(.small)
            }
            
            Button("🔍 Verify Receipt") {
                subscriptionManager.verifyReceipt()
            }
            .buttonStyle(.bordered)
            .tint(.blue)
            .controlSize(.small)
            
            Text("Note: Apple handles trials automatically via subscription introductory offers")
                .font(.caption2)
                .foregroundColor(.secondary)
            
            // Receipt verification results
            if let receiptData = subscriptionManager.receiptData {
                VStack(alignment: .leading, spacing: 4) {
                    Text("🔍 Receipt Verification:")
                        .font(.caption)
                        .fontWeight(.semibold)
                    
                    Text(verbatim: "isInBillingRetryPeriod: \(receiptData.isInBillingRetryPeriod)")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                    
                    Text(verbatim: "isTrialPeriod: \(receiptData.isTrialPeriod)")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                    
                    Text(verbatim: "expiresDate: \(receiptData.expiresDate?.description ?? "nil")")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                    
                    Text(verbatim: "productId: \(receiptData.productId ?? "nil")")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
                .padding(.top, 8)
            }
        }
    }
}
#endif

// MARK: - About Section

struct AboutSection: View {
    var body: some View {
        Section("About") {
            HStack {
                Image(systemName: "info.circle")
                    .foregroundColor(.blue)
                Text("Version")
                Spacer()
                Text("1.5")
                    .foregroundColor(.secondary)
            }
            
            Link(destination: URL(string: "https://ozzzik.github.io/WaterReminderApp/privacy-policy.html")!) {
                HStack {
                    Image(systemName: "hand.raised")
                        .foregroundColor(.blue)
                    Text("Privacy Policy")
                    Spacer()
                    Image(systemName: "chevron.right")
                        .foregroundColor(.secondary)
                        .font(.caption)
                }
            }
            
            Link(destination: URL(string: "https://www.apple.com/legal/internet-services/itunes/dev/stdeula/")!) {
                HStack {
                    Image(systemName: "doc.text")
                        .foregroundColor(.blue)
                    Text("Terms of Use (EULA)")
                    Spacer()
                    Image(systemName: "chevron.right")
                        .foregroundColor(.secondary)
                        .font(.caption)
                }
            }
        }
    }
}

#Preview {
    SettingsView()
        .environmentObject(WaterReminderManager())
        .environmentObject(NotificationManager())
        .environmentObject(RatingManager())
        .environmentObject(SubscriptionManager.shared)
}
