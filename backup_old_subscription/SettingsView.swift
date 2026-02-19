import SwiftUI
import UserNotifications

struct SettingsView: View {
    @EnvironmentObject var waterReminderManager: WaterReminderManager
    @EnvironmentObject var notificationManager: NotificationManager
    @EnvironmentObject var subscriptionManager: SubscriptionManager
    
    @State private var showingDebugOptions = false
    
    let reminderIntervalOptions: [(TimeInterval, String)] = [
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
                WaterIntakeSection()
                ReminderSettingsSection(reminderIntervalOptions: reminderIntervalOptions)
                SubscriptionSection()
                DebugControlsSection(showingDebugOptions: $showingDebugOptions)
                VersionSection()
            }
            .navigationTitle("Settings")
            .onAppear {
                waterReminderManager.loadSettings()
                notificationManager.requestNotificationPermission()
                subscriptionManager.checkTrialStatus()
                Task {
                    await subscriptionManager.updateSubscriptionStatus()
                }
            }
        }
    }
}

struct WaterIntakeSection: View {
    @EnvironmentObject var waterReminderManager: WaterReminderManager
    
    var body: some View {
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
                    Text("\(Int(waterReminderManager.waterIntakeGoal)) cups")
                                .font(.title2)
                                .fontWeight(.bold)
                                .foregroundColor(.blue)
                        }
                        
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
                        Text("\(Int(waterReminderManager.waterIntakeGoal)) cups")
                                    .font(.caption)
                                    .fontWeight(.semibold)
                                    .foregroundColor(.blue)
                            }
                        }
                    }
                    .padding(.vertical, 8)
        }
    }
}

struct ReminderSettingsSection: View {
    @EnvironmentObject var waterReminderManager: WaterReminderManager
    @EnvironmentObject var notificationManager: NotificationManager
    
    let reminderIntervalOptions: [(TimeInterval, String)]
    
    var body: some View {
                Section("Reminder Settings") {
                    HStack {
                        Image(systemName: "bell")
                            .foregroundColor(.blue)
                        Text("Enable Reminders")
                        Spacer()
                Toggle(isOn: $waterReminderManager.isReminderEnabled) {
                    EmptyView()
                }
                            .labelsHidden()
                .onChange(of: waterReminderManager.isReminderEnabled) { _, newValue in
                    if newValue {
                        notificationManager.requestNotificationPermission()
                        waterReminderManager.scheduleReminders()
                    } else {
                        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
                        print("🔕 All pending notifications cancelled.")
                    }
                                waterReminderManager.saveSettingsManually()
                            }
                    }
                    
            if waterReminderManager.isReminderEnabled {
                Picker(selection: $waterReminderManager.reminderInterval, label: 
                        HStack {
                            Image(systemName: "hourglass")
                                .foregroundColor(.blue)
                            Text("Reminder Interval")
                        }
                ) {
                    ForEach(reminderIntervalOptions, id: \.0) { interval, description in
                        Text(description).tag(interval)
                    }
                }
                .onChange(of: waterReminderManager.reminderInterval) { _, _ in
                    waterReminderManager.scheduleReminders()
                    waterReminderManager.saveSettingsManually()
                }
                
                DatePicker(selection: $waterReminderManager.startTime, displayedComponents: .hourAndMinute) {
                    HStack {
                        Image(systemName: "hourglass.bottomhalf.fill")
                            .foregroundColor(.blue)
                        Text("Start Time")
                    }
                }
                .onChange(of: waterReminderManager.startTime) { _, newTime in
                    updateStartTime(newTime)
                    waterReminderManager.scheduleReminders()
                                waterReminderManager.saveSettingsManually()
                }
                
                DatePicker(selection: $waterReminderManager.endTime, displayedComponents: .hourAndMinute) {
                                HStack {
                        Image(systemName: "hourglass.tophalf.fill")
                            .foregroundColor(.blue)
                        Text("End Time")
                    }
                }
                .onChange(of: waterReminderManager.endTime) { _, newTime in
                    updateEndTime(newTime)
                    waterReminderManager.scheduleReminders()
                    waterReminderManager.saveSettingsManually()
                }
            }
        }
    }
    
    private func updateStartTime(_ start: Date) {
        let calendar = Calendar.current
        var startComponents = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: waterReminderManager.startTime)
        startComponents.hour = calendar.dateComponents([.hour], from: start).hour
        startComponents.minute = calendar.dateComponents([.minute], from: start).minute
        if let newStartTime = calendar.date(from: startComponents) {
            waterReminderManager.startTime = newStartTime
        }
    }
    
    private func updateEndTime(_ end: Date) {
        let calendar = Calendar.current
        var endComponents = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: waterReminderManager.endTime)
        endComponents.hour = calendar.dateComponents([.hour], from: end).hour
        endComponents.minute = calendar.dateComponents([.minute], from: end).minute
        if let endTime = calendar.date(from: endComponents) {
            waterReminderManager.endTime = endTime
        }
    }
}

struct SubscriptionSection: View {
    @EnvironmentObject var subscriptionManager: SubscriptionManager
    
    private func formatDate(_ date: Date?) -> String {
        guard let date = date else { return "Unknown" }
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
    
    private func formatTimeRemaining(_ date: Date?) -> String {
        guard let date = date else { return "Unknown" }
        let timeInterval = date.timeIntervalSinceNow
        if timeInterval <= 0 {
            return "Expired"
        }
        let hours = Int(timeInterval) / 3600
        let minutes = Int(timeInterval.truncatingRemainder(dividingBy: 3600)) / 60
        let seconds = Int(timeInterval) % 60
        return String(format: "%02d:%02d:%02d", hours, minutes, seconds)
    }
    
    private func openSubscriptionManagement() {
        // For sandbox testing, show alert instead of opening iTunes
        #if DEBUG
        print("🧪 DEBUG: Manage Subscription button pressed - sandbox mode")
        // In sandbox mode, this would normally open iTunes which doesn't work
        // For testing, we'll just log this action
        #else
        if let url = URL(string: "https://apps.apple.com/account/subscriptions") {
            UIApplication.shared.open(url)
        }
        #endif
    }
    
    var body: some View {
        Section("Subscription") {
            VStack {
                if subscriptionManager.isPremiumActive {
                HStack {
                    Image(systemName: "checkmark.seal.fill")
                        .foregroundColor(.green)
                    Text("Premium Active")
                    Spacer()
                    if subscriptionManager.isSubscriptionCancelled {
                        Text("Cancelled")
                            .foregroundColor(.red)
                    }
                }
                
                if subscriptionManager.subscriptionExpirationDate != nil {
                    HStack {
                        Image(systemName: "calendar")
                            .foregroundColor(.blue)
                        Text(subscriptionManager.isSubscriptionCancelled ? "Active until" : "Renews")
                        Spacer()
                        Text(formatDate(subscriptionManager.subscriptionExpirationDate))
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    
                    if subscriptionManager.isSubscriptionCancelled {
                        HStack {
                            Image(systemName: "hourglass.badge.minus")
                                .foregroundColor(.red)
                            Text("Time Remaining")
                            Spacer()
                            Text(formatTimeRemaining(subscriptionManager.subscriptionExpirationDate))
                                .font(.subheadline)
                                .foregroundColor(.red)
                                .monospacedDigit()
                        }
                        Text("Subscription will be deactivated on \(formatDate(subscriptionManager.subscriptionExpirationDate)).")
                                    .font(.caption)
                            .foregroundColor(.red)
                    }
                            }
                
                        VStack(spacing: 8) {
                            // DIRECT CANCEL - Bypasses Apple's broken UI
                            Button("🎯 DIRECT CANCEL (BYPASS APPLE'S UI)") {
                                Task {
                                    await subscriptionManager.directCancelSubscription()
                                }
                            }
                            .foregroundColor(.white)
                            .fontWeight(.bold)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.green)
                            .cornerRadius(10)
                            
                            // FORCE CANCEL - Aggressive approach
                            Button("🚨 FORCE CANCEL (AGGRESSIVE)") {
                                Task {
                                    await subscriptionManager.forceCancelCurrentSubscription()
                                }
                            }
                            .foregroundColor(.white)
                            .fontWeight(.bold)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.red)
                            .cornerRadius(10)
                            
                            HStack {
                                Button("Manage (Broken Apple UI)") {
                                    openSubscriptionManagement()
                                }
                                .font(.caption)
                                .foregroundColor(.gray)
                                
                                #if DEBUG
                                // For sandbox testing - bypass App Store cancellation
                                Button("Simulate Cancellation") {
                                    subscriptionManager.cancelSubscription()
                                }
                                .font(.caption)
                                .foregroundColor(.orange)
                                #endif
                            }
                        }
                    } else {
                        HStack {
                            Image(systemName: "star.fill")
                                .foregroundColor(.yellow)
                            Text("Upgrade to Premium")
                            Spacer()
                    Image(systemName: "chevron.right")
                        .foregroundColor(.secondary)
                }
                .contentShape(Rectangle())
                .onTapGesture {
                    // Show paywall
                }
                }
            }
        }
    }
}

struct DebugControlsSection: View {
    @EnvironmentObject var subscriptionManager: SubscriptionManager
    @Binding var showingDebugOptions: Bool
    @State private var showingAlert = false
    @State private var alertMessage = ""
    
    var body: some View {
        Section("Debug Controls") {
            VStack {
                Toggle(isOn: $showingDebugOptions.animation()) {
                    HStack {
                        Image(systemName: "wrench.and.screwdriver.fill")
                            .foregroundColor(.orange)
                        Text("Developer Tools")
                    }
                }
                
                if showingDebugOptions {
                    VStack(alignment: .leading, spacing: 15) {
                        // Status Display
                        StatusDisplaySection()
                        
                        // Quick Actions
                        QuickActionsSection()
                        
                        // Trial Controls
                        TrialControlsSection()
                        
                        // Subscription Controls
                        SubscriptionControlsSection()
                        
                        // System Controls
                        SystemControlsSection()
                    }
                }
            }
        }
                .alert("Debug Action", isPresented: $showingAlert) {
                    Button("OK") { }
                } message: {
                    Text(alertMessage)
                }
                .alert("Direct Cancel Result", isPresented: $subscriptionManager.showingDirectCancelAlert) {
                    Button("OK") {
                        subscriptionManager.showingDirectCancelAlert = false
                    }
                } message: {
                    Text(subscriptionManager.directCancelResult)
                }
                .sheet(isPresented: $subscriptionManager.showingDiagnosticReport) {
                    DiagnosticReportView()
                }
    }
    
    private func showAlert(_ message: String) {
        alertMessage = message
        showingAlert = true
    }
    
    // MARK: - Status Display
    
    @ViewBuilder
    private func StatusDisplaySection() -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Current Status")
                .font(.headline)
                .foregroundColor(.primary)
            
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    StatusRow(
                        label: "Trial",
                        status: subscriptionManager.isTrialActive ? "Active" : "Inactive",
                        color: subscriptionManager.isTrialActive ? .green : .red
                    )
                    
                    StatusRow(
                        label: "Premium",
                        status: subscriptionManager.isPremiumActive ? "Active" : "Inactive",
                        color: subscriptionManager.isPremiumActive ? .green : .red
                    )
                    
                    StatusRow(
                        label: "Trial Used",
                        status: subscriptionManager.hasUsedTrial ? "Yes" : "No",
                        color: subscriptionManager.hasUsedTrial ? .red : .green
                    )
                }
                
                Spacer()
                
                if subscriptionManager.isTrialActive {
                    VStack {
                        Text("Trial Time")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Text(String(format: "%02d:%02d", 
                                   Int(subscriptionManager.trialTimeRemaining) / 60, 
                                   Int(subscriptionManager.trialTimeRemaining) % 60))
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.orange)
                            .monospacedDigit()
                    }
                }
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(8)
    }
    
    @ViewBuilder
    private func StatusRow(label: String, status: String, color: Color) -> some View {
        HStack {
            Text(label)
                .font(.caption)
                .foregroundColor(.secondary)
            Spacer()
            Text(status)
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundColor(color)
        }
    }
    
    // MARK: - Quick Actions
    
    @ViewBuilder
    private func QuickActionsSection() -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Quick Actions")
                .font(.headline)
                .foregroundColor(.primary)
            
                        HStack(spacing: 10) {
                            Button("Reset All") {
                                subscriptionManager.resetTrial()
                                subscriptionManager.deactivateSubscription()
                                subscriptionManager.resetReminderSettings()
                                showAlert("All settings reset to default state")
                            }
                            .buttonStyle(.borderedProminent)
                            .tint(.red)
                            .controlSize(.small)
                            
                        Button("Clear All Data") {
                            subscriptionManager.clearAllData()
                            showAlert("All subscription and trial data cleared")
                        }
                        .buttonStyle(.borderedProminent)
                        .tint(.purple)
                        .controlSize(.small)
                        
                        Button("🔍 Run Diagnostics") {
                            subscriptionManager.runComprehensiveDiagnostics()
                        }
                        .buttonStyle(.borderedProminent)
                        .tint(.cyan)
                        .controlSize(.small)
                            
                            Button("🚨 EMERGENCY CLEANUP") {
                                subscriptionManager.emergencyPhantomSubscriptionCleanup()
                                showAlert("Emergency cleanup started! Check console for detailed steps.")
                            }
                            .buttonStyle(.borderedProminent)
                            .tint(.red)
                            .controlSize(.small)
                            
                            Button("🚨 FORCE CANCEL PHANTOM") {
                                subscriptionManager.forceCancelPhantomSubscription()
                                showAlert("Opening App Store to manually cancel phantom subscription")
                            }
                            .buttonStyle(.borderedProminent)
                            .tint(.orange)
                            .controlSize(.small)
                            
                            Button("☢️ NUCLEAR OPTION") {
                                Task {
                                    await subscriptionManager.nuclearOptionCancelAllTransactions()
                                    showAlert("Nuclear option executed - check console for details")
                                }
                            }
                            .buttonStyle(.borderedProminent)
                            .tint(.purple)
                            .controlSize(.small)
                            
                            Button("Enable Reminders") {
                                subscriptionManager.resetReminderSettings()
                                showAlert("Reminder settings enabled")
                            }
                            .buttonStyle(.borderedProminent)
                            .tint(.blue)
                            .controlSize(.small)
                            
                            Spacer()
                        }
        }
    }
    
    // MARK: - Trial Controls
    
    @ViewBuilder
    private func TrialControlsSection() -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Trial Controls")
                .font(.headline)
                .foregroundColor(.primary)
            
            VStack(spacing: 8) {
                HStack(spacing: 10) {
                    Button("Start 3min Trial") {
                        subscriptionManager.startTrial()
                        showAlert("3-minute trial started")
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(.green)
                    .controlSize(.small)
                    
                    Button("End Trial Now") {
                        subscriptionManager.endTrial()
                        showAlert("Trial ended - paywall shown")
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(.red)
                    .controlSize(.small)
                    
                    Spacer()
                }
                
                HStack(spacing: 10) {
                    Button("Reset Trial") {
                        subscriptionManager.resetTrial()
                        showAlert("Trial reset - can start new trial")
                    }
                    .buttonStyle(.bordered)
                    .tint(.blue)
                    .controlSize(.small)
                    
                    Spacer()
                }
            }
        }
    }
    
    // MARK: - Subscription Controls
    
    @ViewBuilder
    private func SubscriptionControlsSection() -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Subscription Controls")
                .font(.headline)
                .foregroundColor(.primary)
            
            VStack(spacing: 8) {
                HStack(spacing: 10) {
                    Button("Activate (30 days)") {
                        #if DEBUG
                        subscriptionManager.activateSubscription()
                        #endif
                        showAlert("Subscription activated for 30 days")
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(.purple)
                    .controlSize(.small)
                    
                            Button("Cancel Subscription") {
                                subscriptionManager.cancelSubscription()
                                #if DEBUG
                                showAlert("Subscription cancelled - active for 30 days")
                                #else
                                showAlert("Opening App Store subscription management...")
                                #endif
                            }
                    .buttonStyle(.borderedProminent)
                    .tint(.orange)
                    .controlSize(.small)
                    
                    Spacer()
                }
                
                HStack(spacing: 10) {
                    Button("Deactivate All") {
                        #if DEBUG
                        subscriptionManager.deactivateSubscription()
                        #endif
                        showAlert("All subscription data cleared")
                    }
                    .buttonStyle(.bordered)
                    .tint(.red)
                    .controlSize(.small)
                    
                    Spacer()
                }
            }
        }
    }
    
    // MARK: - System Controls
    
    @ViewBuilder
    private func SystemControlsSection() -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("System Controls")
                .font(.headline)
                .foregroundColor(.primary)
            
            HStack(spacing: 10) {
                Button("Restore Purchases") {
                    Task {
                        await subscriptionManager.restorePurchases()
                        showAlert("Purchase restoration completed")
                    }
                }
                .buttonStyle(.bordered)
                .tint(.blue)
                .controlSize(.small)
                
                Spacer()
            }
        }
    }
}

struct VersionSection: View {
    var body: some View {
        Section {
                    HStack {
                        Image(systemName: "info.circle")
                            .foregroundColor(.blue)
                        Text("Version")
                        Spacer()
                Text(Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.4")
                            .foregroundColor(.secondary)
            }
        }
    }
}

struct DiagnosticReportView: View {
    @EnvironmentObject var subscriptionManager: SubscriptionManager
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    Text(subscriptionManager.diagnosticReport)
                        .font(.system(.caption, design: .monospaced))
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(8)
                }
                .padding()
            }
            .navigationTitle("Diagnostic Report")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Close") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Copy") {
                        UIPasteboard.general.string = subscriptionManager.diagnosticReport
                    }
                }
            }
        }
    }
}

#Preview {
    SettingsView()
        .environmentObject(WaterReminderManager())
        .environmentObject(NotificationManager())
        .environmentObject(SubscriptionManager())
} 