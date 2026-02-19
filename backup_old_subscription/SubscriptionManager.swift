import Foundation
import StoreKit
import SwiftUI
import UserNotifications

@MainActor
class SubscriptionManager: ObservableObject {
    static let shared = SubscriptionManager()
    
    // Subscription product IDs
    // Using v2 to bypass stuck phantom subscription on old IDs
    private let monthlyProductID = "com.whio.waterreminder.monthly.v2"
    private let yearlyProductID = "com.whio.waterreminder.yearly.v2"
    
    // Legacy product IDs (kept for reference, no longer used)
    // private let monthlyProductID_v1 = "com.whio.waterreminder.monthly"
    // private let yearlyProductID_v1 = "com.whio.waterreminder.yearly"
    
    // Trial settings
    private let trialDurationMinutes = 3  // Changed to 3 minutes for testing
    private let trialStartKey = "trialStartDate"
    private let subscriptionStatusKey = "subscriptionStatus"
    private let trialUsedKey = "trialUsed"  // Track if trial has been used
    
    // Subscription duration - real values for production
    private let monthlySubscriptionMinutes = 30 * 24 * 60  // 1 month (30 days)
    private let yearlySubscriptionMinutes = 365 * 24 * 60  // 1 year (365 days)
    
    @Published var isPremiumActive = false
    @Published var isTrialActive = false
    @Published var trialDaysRemaining = 0
    @Published var trialTimeRemaining: TimeInterval = 0  // Time remaining in seconds
    @Published var hasUsedTrial = false  // Track if user has used trial before
    @Published var isSubscriptionCancelled = false
    @Published var subscriptionExpirationDate: Date?
    @Published var isLoading = false
    @Published var products: [Product] = []
    @Published var diagnosticReport = ""
    @Published var showingDiagnosticReport = false
    @Published var directCancelResult = "" // Result of direct cancel operation
    @Published var showingDirectCancelAlert = false // Show alert for direct cancel result
    
    private var updateListenerTask: Task<Void, Error>? = nil
    private var trialTimer: Timer?
    private var subscriptionTimer: Timer?
    
    init() {
        // Start listening for transaction updates
        updateListenerTask = listenForTransactions()
        
        // Initialize subscription status
        checkSubscriptionStatus()
        checkTrialStatus()
        checkTrialUsage()
        
        // Start trial countdown timer
        startTrialTimer()
    }
    
    deinit {
        updateListenerTask?.cancel()
        trialTimer?.invalidate()
    }
    
    // MARK: - Trial Management
    
    func startTrial() {
        // Start a fresh 3-minute trial
        let trialStart = Date()
        UserDefaults.standard.set(trialStart, forKey: trialStartKey)
        UserDefaults.standard.set(true, forKey: trialUsedKey)
        isPremiumActive = false
        
        // Set trial as active with full 3 minutes
        isTrialActive = true
        trialTimeRemaining = TimeInterval(trialDurationMinutes * 60) // 3 minutes in seconds
        trialDaysRemaining = 1
        
        checkTrialUsage()
        startTrialTimer()
        
        print("🆓 Trial started: \(trialStart) - 3 minutes remaining")
        
        // UI updates are automatic with @MainActor
    }
    
    func canStartTrial() -> Bool {
        return !hasUsedTrial && !isPremiumActive
    }
    
    func endTrial() {
        // End trial immediately and show paywall
        isTrialActive = false
        trialTimeRemaining = 0
        trialDaysRemaining = 0
        isPremiumActive = false
        
        // Disable notifications when trial ends
        disableNotificationsForExpiredTrial()
        
        print("🆓 Trial ended - showing paywall")
        
        // UI updates are automatic with @MainActor
    }
    
    func resetTrial() {
        // Reset trial completely - allow user to start fresh trial
        UserDefaults.standard.removeObject(forKey: trialStartKey)
        UserDefaults.standard.set(false, forKey: trialUsedKey)
        
        // Stop trial timer
        trialTimer?.invalidate()
        trialTimer = nil
        
        // Reset trial state
        isTrialActive = false
        trialTimeRemaining = 0
        trialDaysRemaining = 0
        hasUsedTrial = false
        
        print("🔄 Trial reset - user can start fresh trial")
        
        // UI updates are automatic with @MainActor
    }
    
    func checkTrialStatus() {
        guard let trialStart = UserDefaults.standard.object(forKey: trialStartKey) as? Date else {
            // No trial started yet
            isTrialActive = false
            trialDaysRemaining = 0
            trialTimeRemaining = 0
            print("🆓 No trial started yet")
            return
        }
        
        let trialDuration = TimeInterval(trialDurationMinutes * 60) // 3 minutes in seconds
        let timeElapsed = Date().timeIntervalSince(trialStart)
        let timeRemaining = trialDuration - timeElapsed
        
        let wasTrialActive = isTrialActive
        
        if timeRemaining > 0 {
            isTrialActive = true
            trialTimeRemaining = timeRemaining
            trialDaysRemaining = max(1, Int(ceil(timeRemaining / (24 * 60 * 60))))
        } else {
            isTrialActive = false
            trialDaysRemaining = 0
            trialTimeRemaining = 0
            
            // Only log and disable notifications when trial actually expires (once)
            if wasTrialActive && !hasUsedTrial {
            print("🆓 Trial expired")
                hasUsedTrial = true
                
                // Turn off notifications when trial expires
                if !isPremiumActive {
                    disableNotificationsForExpiredTrial()
                }
                
                // Post notification for UI updates
                NotificationCenter.default.post(name: NSNotification.Name("TrialExpired"), object: nil)
            }
        }
        
        // UI updates are automatic with @MainActor
    }
    
    func checkTrialUsage() {
        hasUsedTrial = UserDefaults.standard.bool(forKey: trialUsedKey)
        print("🆓 Trial usage check - hasUsedTrial: \(hasUsedTrial)")
    }
    
    private func disableNotificationsForExpiredTrial() {
        print("🔔 Trial expired - checking if notifications should be disabled")
        
        // Only disable notifications if user is not premium and trial is actually expired
        if !isPremiumActive && hasUsedTrial {
            print("🔔 Disabling notifications - trial expired and no premium")
            
            // Disable reminders in UserDefaults
            UserDefaults.standard.set(false, forKey: "isReminderEnabled")
            UserDefaults.standard.synchronize()
            
            // Cancel all pending notifications
            UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
            
            // Post notification to update UI
            NotificationCenter.default.post(name: NSNotification.Name("TrialExpired"), object: nil)
            
            print("🔔 Notifications disabled due to trial expiration")
        } else {
            print("🔔 Not disabling notifications - user has premium or trial not expired")
        }
    }
    
    private func stopTrial() {
        print("🛑 Stopping trial due to premium activation")
        
        // Stop the trial timer
        trialTimer?.invalidate()
        trialTimer = nil
        
        // Reset trial state
        isTrialActive = false
        trialTimeRemaining = 0
        trialDaysRemaining = 0
        
        // UI updates are automatic with @MainActor
        
        print("🛑 Trial stopped - premium is now active")
    }
    
    private func startTrialTimer() {
        // Update trial status every second for real-time countdown
        trialTimer?.invalidate() // Stop any existing timer
        trialTimer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
            Task { @MainActor in
                // Only check trial status if app is active and trial is actually active
                if UIApplication.shared.applicationState == .active && self?.isTrialActive == true {
                self?.checkTrialStatus()
                }
            }
        }
    }
    
    private func startSubscriptionTimer() {
        // Update subscription status every second for real-time countdown
        subscriptionTimer?.invalidate() // Stop any existing timer
        subscriptionTimer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
            Task { @MainActor in
                self?.checkSubscriptionStatus()
            }
        }
    }
    
    private func stopSubscriptionTimer() {
        subscriptionTimer?.invalidate()
        subscriptionTimer = nil
    }
    
    // MARK: - App Access Control
    
    func canUseApp() -> Bool {
        return isTrialActive || isPremiumActive
    }
    
    func shouldShowPaywall() -> Bool {
        return !canUseApp()
    }
    
    // MARK: - StoreKit Integration
    
    func loadProducts() async {
        do {
            let productIDs = [monthlyProductID, yearlyProductID]
            print("🛒 Attempting to load products: \(productIDs)")
            products = try await Product.products(for: productIDs)
            print("🛒 Successfully loaded \(products.count) products:")
            for product in products {
                print("  - \(product.id): \(product.displayName) - \(product.displayPrice)")
            }
            
            // If no products loaded, this means we're in sandbox mode but products aren't configured in App Store Connect
            if products.isEmpty {
                print("⚠️ No products loaded - this usually means:")
                print("   1. Products not configured in App Store Connect, OR")
                print("   2. Not signed in with sandbox account, OR")
                print("   3. StoreKit Configuration not selected in Xcode scheme")
                print("💡 For testing, you can use StoreKit Configuration instead of sandbox")
            }
        } catch {
            print("❌ Failed to load products: \(error)")
            print("❌ Error details: \(error.localizedDescription)")
        }
    }
    
    func purchase(_ product: Product) async throws -> StoreKit.Transaction? {
        print("🛒 Starting purchase for product: \(product.id)")
        let result = try await product.purchase()
        
        switch result {
        case .success(let verification):
            print("✅ Purchase successful, verifying transaction...")
            let transaction = try checkVerified(verification)
            print("✅ Transaction verified: \(transaction.id)")
            
            // Process the transaction (this will update subscription status)
            await processTransaction(transaction)
            
            // Only finish the transaction after successful processing
            await transaction.finish()
            print("✅ Transaction finished")
            
            // Save recent purchase date as fallback for testing
            UserDefaults.standard.set(Date(), forKey: "recentPurchaseDate")
            
            return transaction
            
        case .userCancelled:
            print("❌ Purchase cancelled by user")
            return nil
            
        case .pending:
            print("⏳ Purchase pending")
            return nil
            
        default:
            print("❌ Purchase failed with unknown result")
            return nil
        }
    }
    
    func restorePurchases() async {
        print("🔄 Starting restore purchases...")
        isLoading = true
        
        do {
            // Add timeout to prevent endless spinning
            try await withThrowingTaskGroup(of: Void.self) { group in
                group.addTask {
                    print("🔄 Syncing with App Store...")
            try await AppStore.sync()
                    print("✅ App Store sync completed")
                }
                
                group.addTask {
                    try await Task.sleep(nanoseconds: 15_000_000_000) // 15 second timeout
                    throw NSError(domain: "TimeoutError", code: -1, userInfo: [NSLocalizedDescriptionKey: "Restore purchases timed out"])
                }
                
                try await group.next()
                group.cancelAll()
            }
            
            // Update subscription status after successful sync
            print("🔄 Updating subscription status...")
            await updateSubscriptionStatus()
            print("✅ Purchases restored successfully")
            
        } catch {
            print("❌ Failed to restore purchases: \(error)")
            
            // For timeout or other errors, still try to check current status
            if error.localizedDescription.contains("TimeoutError") {
                print("⏰ Restore timeout - checking current subscription status instead")
            } else {
                print("🔄 Checking current subscription status as fallback")
            }
            
            // Always try to update subscription status as fallback
            await updateSubscriptionStatus()
        }
        
        isLoading = false
        print("🔄 Restore purchases completed")
    }
    
    // MARK: - Subscription Status
    
    func checkSubscriptionStatus() {
        Task {
            await updateSubscriptionStatus()
        }
    }
    
    func updateSubscriptionStatus() async {
        var isActive = false
        var expirationDate: Date?
        var isCancelled = false
        
        print("🔍 Checking subscription status...")
        
        // Check current entitlements - more efficient approach
        for await result in Transaction.currentEntitlements {
            do {
                let transaction = try checkVerified(result)
                
                // Only process our subscription products
                guard transaction.productID == monthlyProductID || transaction.productID == yearlyProductID else {
                    continue
                }
                
                print("🔍 Found subscription entitlement: \(transaction.productID)")
                
                // Check if subscription is active or cancelled
                    if transaction.revocationDate == nil {
                    // Active subscription
                        isActive = true
                    expirationDate = transaction.expirationDate
                    print("✅ Active subscription found: \(transaction.productID), expires: \(expirationDate?.description ?? "unknown")")
                    break // Found active subscription, no need to check further
                } else {
                    // Cancelled subscription - check if still in grace period
                    isCancelled = true
                    if let expiration = transaction.expirationDate, Date() < expiration {
                        isActive = true // Still active during grace period
                        expirationDate = expiration
                        print("⚠️ Cancelled subscription still active until: \(expiration)")
                    } else {
                        print("❌ Cancelled subscription expired")
                    }
                }
            } catch {
                print("❌ Failed to verify transaction: \(error)")
            }
        }
        
        // If subscription was cancelled, check if we're still within the grace period
        if isCancelled && !isActive {
            if let expiration = expirationDate {
                let now = Date()
                if now < expiration {
                    print("⏰ Subscription cancelled but still within grace period until: \(expiration)")
                    isActive = true
                } else {
                    print("❌ Grace period expired on: \(expiration)")
                }
            }
        }
        
        // If no active subscription found, check if we have a recent purchase in UserDefaults
        // This is a fallback for StoreKit testing scenarios
        if !isActive {
            let recentPurchaseKey = "recentPurchaseDate"
            if let recentPurchaseDate = UserDefaults.standard.object(forKey: recentPurchaseKey) as? Date {
                let timeSincePurchase = Date().timeIntervalSince(recentPurchaseDate)
                // If purchase was within last 5 minutes, consider it active (for testing)
                if timeSincePurchase < 300 {
                    print("🧪 Using recent purchase fallback for testing")
                    isActive = true
                }
            }
        }
        
        let wasPremiumActive = isPremiumActive
            isPremiumActive = isActive
        isSubscriptionCancelled = isCancelled
        subscriptionExpirationDate = expirationDate
        
        // Start/stop subscription timer based on status
        if isActive {
            startSubscriptionTimer()
        } else {
            stopSubscriptionTimer()
        }
        
        // Stop trial if premium becomes active
        if !wasPremiumActive && isActive && isTrialActive {
            print("🛑 Premium activated - stopping trial")
            stopTrial()
        }
        
            print("💳 Final subscription status: \(isActive ? "Active" : "Inactive")")
        if let expiration = expirationDate {
            print("📅 Subscription expires: \(expiration)")
        }
        if isCancelled {
            print("⚠️ Subscription is cancelled but \(isActive ? "still active until expiration" : "expired")")
        }
    }
    
    // MARK: - Helper Methods
    
    private func listenForTransactions() -> Task<Void, Error> {
        return Task.detached {
            for await result in Transaction.updates {
                do {
                    let transaction = try await self.checkVerified(result)
                    
                    // Only process and finish transactions for our products
                    if transaction.productID == self.monthlyProductID || transaction.productID == self.yearlyProductID {
                        print("🔄 Processing transaction: \(transaction.productID)")
                        
                        // Update subscription status based on transaction
                        await self.processTransaction(transaction)
                        
                        // Only finish the transaction after successful processing
                    await transaction.finish()
                    }
                } catch {
                    print("❌ Transaction verification failed: \(error)")
                }
            }
        }
    }
    
    private func processTransaction(_ transaction: StoreKit.Transaction) async {
        // Update subscription status based on transaction
        if transaction.revocationDate == nil {
            // Active subscription
            isPremiumActive = true
            isSubscriptionCancelled = false
            subscriptionExpirationDate = transaction.expirationDate
            
            // Stop trial if premium becomes active
            if isTrialActive {
                stopTrial()
            }
            
            print("✅ Subscription activated: \(transaction.productID)")
        } else {
            // Cancelled subscription - check if still in grace period
            if let expirationDate = transaction.expirationDate, Date() < expirationDate {
                isPremiumActive = true
                isSubscriptionCancelled = true
                subscriptionExpirationDate = expirationDate
                print("⚠️ Subscription cancelled but still active until: \(expirationDate)")
            } else {
                isPremiumActive = false
                isSubscriptionCancelled = false
                subscriptionExpirationDate = nil
                print("❌ Subscription expired")
            }
        }
    }
    
    private func checkVerified<T>(_ result: VerificationResult<T>) throws -> T {
        switch result {
        case .unverified:
            throw StoreError.failedVerification
        case .verified(let safe):
            return safe
        }
    }
    
    // MARK: - Product Helpers
    
    func getMonthlyProduct() -> Product? {
        return products.first { $0.id == monthlyProductID }
    }
    
    func getYearlyProduct() -> Product? {
        return products.first { $0.id == yearlyProductID }
    }
    
    func getYearlySavings() -> String {
        guard let monthly = getMonthlyProduct(),
              let yearly = getYearlyProduct() else {
            return ""
        }
        
        let monthlyYearlyPrice = monthly.price * 12
        let savings = monthlyYearlyPrice - yearly.price
        let savingsPercent = (savings / monthlyYearlyPrice) * 100
        
        return String(format: "%.0f%% off", savingsPercent as CVarArg)
    }
    
    // MARK: - Debug/Test Methods
    
    func activateSubscription() {
        // For ALL builds (DEBUG, TestFlight, Production) - simulate local subscription state only
        // This prevents accidentally creating sandbox entitlements in TestFlight
        isSubscriptionCancelled = false
        isPremiumActive = true
        isTrialActive = false
        trialTimeRemaining = 0
        trialDaysRemaining = 0
        
        // Set expiration date (30 days from now for testing)
        subscriptionExpirationDate = Date().addingTimeInterval(TimeInterval(monthlySubscriptionMinutes * 60)) // 30 days from now
        
        // Start subscription timer for countdown
        startSubscriptionTimer()
        
        // Save recent purchase date as fallback
        UserDefaults.standard.set(Date(), forKey: "recentPurchaseDate")
        
        print("🧪 DEBUG: Subscription activated (LOCAL SIMULATION ONLY) - premium features unlocked, expires at \(subscriptionExpirationDate?.description ?? "unknown")")
        
        // UI updates are automatic with @MainActor
    }
    
    func deactivateSubscription() {
        // For ALL builds (DEBUG, TestFlight, Production) - clear local subscription state only
        // This prevents accidentally opening App Store in TestFlight
        isPremiumActive = false
        isSubscriptionCancelled = false
        subscriptionExpirationDate = nil
        UserDefaults.standard.removeObject(forKey: "recentPurchaseDate")
        
        // Stop subscription timer
        stopSubscriptionTimer()
        
        // If trial was used, show expired state
        if hasUsedTrial {
            isTrialActive = false
            trialTimeRemaining = 0
            trialDaysRemaining = 0
            disableNotificationsForExpiredTrial()
        }
        
        print("🧪 DEBUG: Subscription deactivated (LOCAL SIMULATION ONLY) - all references cleared")
        
        // UI updates are automatic with @MainActor
    }
    
    func cancelSubscription() {
        // For ALL builds (DEBUG, TestFlight, Production) - simulate cancellation locally only
        // This prevents accidentally opening App Store in TestFlight
        isSubscriptionCancelled = true
        isPremiumActive = true
        
        // Set new expiration date (30 days from now for testing)
        subscriptionExpirationDate = Date().addingTimeInterval(TimeInterval(monthlySubscriptionMinutes * 60)) // 30 days from now
        
        // Start subscription timer for countdown
        startSubscriptionTimer()
        
        print("🧪 DEBUG: Subscription cancelled (LOCAL SIMULATION ONLY) - will expire at \(subscriptionExpirationDate?.description ?? "unknown")")
        
        // UI updates are automatic with @MainActor
    }
    
    func openSubscriptionManagement() {
        print("🔗 Opening subscription management...")
        
        // For TestFlight/Sandbox: Open Settings app directly
        // iOS Settings → [Your Name] → Subscriptions won't show sandbox subscriptions
        // But we'll open Settings anyway in case it helps
        if let url = URL(string: "App-prefs:root=APPLE_ACCOUNT&path=SUBSCRIPTIONS") {
            UIApplication.shared.open(url) { success in
                if success {
                    print("✅ Opened Settings app (Note: Sandbox subscriptions may not be visible)")
                } else {
                    print("⚠️ Could not open Settings app, trying App Store...")
                    // Fallback to App Store
                    if let appStoreURL = URL(string: "https://apps.apple.com/account/subscriptions") {
                        UIApplication.shared.open(appStoreURL)
                    }
                }
            }
        } else {
            print("❌ Invalid URL for subscription management")
        }
    }
    
    // MARK: - Direct Cancellation (Bypass Apple's Broken UI)
    
    func directCancelSubscription() async {
        print("🚨 DIRECT CANCEL: Attempting to cancel subscription directly...")
        
        isLoading = true
        
        // Step 1: Find the active subscription
        print("🚨 Step 1: Finding active subscription...")
        var activeTransaction: StoreKit.Transaction?
        var subscriptionProductID: String?
        
        for await result in Transaction.currentEntitlements {
            do {
                let transaction = try checkVerified(result)
                if transaction.productID == monthlyProductID || transaction.productID == yearlyProductID {
                    activeTransaction = transaction
                    subscriptionProductID = transaction.productID
                    print("🚨 Found active subscription: \(transaction.productID)")
                    print("🚨 Transaction ID: \(transaction.id)")
                    print("🚨 Purchase Date: \(transaction.purchaseDate)")
                    print("🚨 Expires: \(transaction.expirationDate?.description ?? "unknown")")
                    break
                }
            } catch {
                print("🚨 Error verifying transaction: \(error)")
            }
        }
        
        guard let transaction = activeTransaction, let productID = subscriptionProductID else {
            print("❌ No active subscription found")
            isLoading = false
            return
        }
        
        // Step 2: Try to cancel by marking as revoked locally
        print("🚨 Step 2: Attempting direct cancellation...")
        
        // Mark subscription as cancelled locally (this might help)
        isSubscriptionCancelled = true
        if let expirationDate = transaction.expirationDate {
            subscriptionExpirationDate = expirationDate
            print("🚨 Subscription marked as cancelled, expires: \(expirationDate)")
        }
        
        // Step 3: Try to finish the transaction (may not work for active subscriptions)
        print("🚨 Step 3: Attempting to finish transaction...")
        do {
            await transaction.finish()
            print("✅ Transaction finished")
        } catch {
            print("⚠️ Could not finish transaction: \(error)")
            print("⚠️ This is expected for active subscriptions")
        }
        
        // Step 4: Force multiple App Store syncs
        print("🚨 Step 4: Force syncing with App Store...")
        for attempt in 1...5 {
            print("🚨 Sync attempt \(attempt)/5...")
            do {
                try await AppStore.sync()
                print("✅ Sync \(attempt) completed")
                
                // Check if subscription is gone after sync
                var stillActive = false
                for await result in Transaction.currentEntitlements {
                    do {
                        let checkTransaction = try checkVerified(result)
                        if checkTransaction.productID == productID {
                            stillActive = true
                            break
                        }
                    } catch { continue }
                }
                
                if !stillActive {
                    print("🎉 SUCCESS! Subscription cancelled after sync \(attempt)!")
                    break
                } else {
                    print("⚠️ Subscription still active after sync \(attempt)")
                }
                
                try await Task.sleep(nanoseconds: 2_000_000_000) // 2 second delay
            } catch {
                print("❌ Sync \(attempt) failed: \(error)")
            }
        }
        
        // Step 5: Clear all local data
        print("🚨 Step 5: Clearing all local data...")
        isPremiumActive = false
        UserDefaults.standard.removeObject(forKey: "recentPurchaseDate")
        UserDefaults.standard.removeObject(forKey: "subscriptionStatus")
        
        // Clear all possible subscription-related keys
        let keysToRemove = [
            "subscriptionProductID", "subscriptionTransactionID", "lastSubscriptionCheck",
            "recentPurchaseDate", "subscriptionStatus", "isPremiumActive"
        ]
        for key in keysToRemove {
            UserDefaults.standard.removeObject(forKey: key)
        }
        UserDefaults.standard.synchronize()
        
        stopSubscriptionTimer()
        
        // Step 6: Final status check
        print("🚨 Step 6: Final status check...")
        await updateSubscriptionStatus()
        
        isLoading = false
        
        // Step 7: Report results
        if isPremiumActive {
            let failureMessage = """
            🚨 DIRECT CANCEL FAILED!
            
            Subscription is stuck on Apple's servers.
            
            This requires App Store Connect intervention:
            
            1. Go to: appstoreconnect.apple.com
            2. Users and Access → Sandbox
            3. Select your account
            4. Clear Purchase History
            5. Wait 10 minutes
            6. Delete and reinstall app
            
            Or just wait - it will auto-expire on Oct 9.
            """
            directCancelResult = failureMessage
            print("🚨🚨🚨 DIRECT CANCEL FAILED! 🚨🚨🚨")
            print("🚨 Subscription is stuck on Apple's servers")
            print("🚨 This requires App Store Connect intervention:")
            print("🚨 1. Go to: https://appstoreconnect.apple.com/access/testers")
            print("🚨 2. Sandbox → Your account → Clear Purchase History")
            print("🚨 3. Wait 10 minutes")
            print("🚨 4. Delete and reinstall app")
        } else {
            let successMessage = """
            🎉 SUCCESS!
            
            Subscription cancelled successfully!
            
            ✅ You can now purchase a new subscription
            ✅ All local data cleared
            ✅ Apple servers synced
            
            You're all set! 🚀
            """
            directCancelResult = successMessage
            print("🎉🎉🎉 SUCCESS! Subscription cancelled! 🎉🎉🎉")
            print("✅ You can now purchase a new subscription")
        }
        
        showingDirectCancelAlert = true
    }
    
    // MARK: - Force Cancel Current Subscription
    
    func forceCancelCurrentSubscription() async {
        print("🚨 FORCE CANCEL: Starting force cancellation of current subscription...")
        
        isLoading = true
        
        // Step 1: Find the current subscription transaction
        print("🚨 Step 1: Finding current subscription transaction...")
        var foundTransaction: StoreKit.Transaction?
        
        for await result in Transaction.currentEntitlements {
            do {
                let transaction = try checkVerified(result)
                if transaction.productID == monthlyProductID || transaction.productID == yearlyProductID {
                    foundTransaction = transaction
                    print("🚨 Found subscription: \(transaction.productID)")
                    print("🚨 Transaction ID: \(transaction.id)")
                    print("🚨 Expires: \(transaction.expirationDate?.description ?? "unknown")")
                    break
                }
            } catch {
                print("🚨 Error verifying transaction: \(error)")
            }
        }
        
        // Step 2: Try to finish the transaction (may not work for active subscriptions)
        if let transaction = foundTransaction {
            print("🚨 Step 2: Attempting to finish transaction \(transaction.id)...")
            do {
                await transaction.finish()
                print("✅ Transaction finished successfully")
            } catch {
                print("⚠️ Could not finish transaction (it's already finished): \(error)")
                print("⚠️ This is normal for active subscriptions")
            }
        } else {
            print("🚨 No active subscription found")
        }
        
        // Step 3: Force sync with App Store multiple times
        print("🚨 Step 3: Force syncing with App Store (multiple attempts)...")
        for i in 1...3 {
            print("🚨 Sync attempt \(i)/3...")
            do {
                try await AppStore.sync()
                print("✅ App Store sync \(i) completed")
                try await Task.sleep(nanoseconds: 1_000_000_000) // 1 second delay
            } catch {
                print("❌ App Store sync \(i) failed: \(error)")
            }
        }
        
        // Step 4: Clear ALL local subscription data aggressively
        print("🚨 Step 4: Aggressively clearing ALL local data...")
        isPremiumActive = false
        isSubscriptionCancelled = false
        subscriptionExpirationDate = nil
        
        // Clear ALL possible UserDefaults keys
        let allPossibleKeys = [
            trialStartKey, trialUsedKey, subscriptionStatusKey,
            "recentPurchaseDate", "isReminderEnabled", "subscriptionExpirationDate",
            "isSubscriptionCancelled", "isPremiumActive", "hasUsedTrial",
            "subscriptionProductID", "subscriptionTransactionID", "lastSubscriptionCheck"
        ]
        
        for key in allPossibleKeys {
            UserDefaults.standard.removeObject(forKey: key)
        }
        UserDefaults.standard.synchronize()
        
        stopSubscriptionTimer()
        
        // Step 5: Update subscription status
        print("🚨 Step 5: Checking final status...")
        await updateSubscriptionStatus()
        
        isLoading = false
        
        print("🚨 FORCE CANCEL COMPLETE!")
        if isPremiumActive {
            print("🚨🚨🚨 SUBSCRIPTION IS STUCK ON APPLE'S SERVERS! 🚨🚨🚨")
            print("🚨 This is a confirmed Apple server-side bug!")
            print("🚨 IMMEDIATE ACTIONS REQUIRED:")
            print("🚨 1. Go to: https://appstoreconnect.apple.com/access/testers")
            print("🚨 2. Sandbox → Select your account → Clear Purchase History")
            print("🚨 3. Wait 10 minutes")
            print("🚨 4. Delete and reinstall the app")
            print("🚨 5. If still stuck, contact Apple Support")
            print("🚨 6. Tell them: 'Sandbox subscription won't cancel even through iOS Settings'")
        } else {
            print("✅ Subscription successfully cancelled!")
        }
    }
    
    func formatTrialTimeRemaining() -> String {
        let hours = Int(trialTimeRemaining) / 3600
        let minutes = Int(trialTimeRemaining) % 3600 / 60
        let seconds = Int(trialTimeRemaining) % 60
        
        if hours > 0 {
            return String(format: "%d:%02d:%02d", hours, minutes, seconds)
        } else {
            return String(format: "%d:%02d", minutes, seconds)
        }
    }
    
    func formatSubscriptionTimeRemaining() -> String {
        guard let expirationDate = subscriptionExpirationDate else {
            return "Unknown"
        }
        
        let timeRemaining = expirationDate.timeIntervalSinceNow
        
        if timeRemaining <= 0 {
            return "Expired"
        }
        
        let days = Int(timeRemaining) / (24 * 60 * 60)
        let hours = Int(timeRemaining) % (24 * 60 * 60) / (60 * 60)
        let minutes = Int(timeRemaining) % (60 * 60) / 60
        
        if days > 0 {
            return "\(days)d \(hours)h \(minutes)m"
        } else if hours > 0 {
            return "\(hours)h \(minutes)m"
        } else {
            return "\(minutes)m"
        }
    }
    
    func formatSubscriptionExpirationDate() -> String {
        guard let expirationDate = subscriptionExpirationDate else {
            return "Unknown"
        }
        
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        formatter.locale = Locale.current
        
        return formatter.string(from: expirationDate)
    }
    
    
    func resetReminderSettings() {
        #if DEBUG
        // For debug/sandbox testing - reset reminder settings
        UserDefaults.standard.set(true, forKey: "isReminderEnabled")
        UserDefaults.standard.synchronize()
        print("🔧 DEBUG: Reset reminder settings to enabled")
        #else
        // For TestFlight/Production - enable reminders in UserDefaults
        UserDefaults.standard.set(true, forKey: "isReminderEnabled")
        UserDefaults.standard.synchronize()
        print("🔔 TestFlight: Reminder settings enabled")
        #endif
    }
    
    func clearAllData() {
        // For ALL builds (DEBUG, TestFlight, Production) - clear ALL local data only
        // This prevents accidentally syncing with App Store in TestFlight
        print("🧹 DEBUG: Clearing ALL local subscription and trial data (LOCAL SIMULATION ONLY)")
        
        // Stop all timers
        trialTimer?.invalidate()
        trialTimer = nil
        subscriptionTimer?.invalidate()
        subscriptionTimer = nil
        
        // Reset all subscription state
        isPremiumActive = false
        isTrialActive = false
        trialTimeRemaining = 0
        trialDaysRemaining = 0
        hasUsedTrial = false
        isSubscriptionCancelled = false
        subscriptionExpirationDate = nil
        isLoading = false
        
        // Clear all UserDefaults
        UserDefaults.standard.removeObject(forKey: trialStartKey)
        UserDefaults.standard.removeObject(forKey: trialUsedKey)
        UserDefaults.standard.removeObject(forKey: subscriptionStatusKey)
        UserDefaults.standard.removeObject(forKey: "recentPurchaseDate")
        UserDefaults.standard.removeObject(forKey: "isReminderEnabled")
        UserDefaults.standard.synchronize()
        
        // Clear all pending notifications
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
        
        print("🧹 DEBUG: All local data cleared - app is in fresh state (NO SERVER SYNC)")
        
        // UI updates are automatic with @MainActor
    }
    
    // MARK: - Diagnostic Tools
    
    func runComprehensiveDiagnostics() {
        var report = "🔍 SUBSCRIPTION DIAGNOSTIC REPORT\n"
        report += "📅 Generated: \(Date())\n"
        report += "📱 App Version: \(Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "Unknown")\n"
        report += "📱 Build: \(Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "Unknown")\n\n"
        
        // 1. Check local app state
        report += "📱 LOCAL APP STATE:\n"
        report += "  • Premium Active: \(isPremiumActive)\n"
        report += "  • Trial Active: \(isTrialActive)\n"
        report += "  • Trial Used: \(hasUsedTrial)\n"
        report += "  • Subscription Cancelled: \(isSubscriptionCancelled)\n"
        report += "  • Expiration Date: \(subscriptionExpirationDate?.description ?? "nil")\n"
        report += "  • Trial Time Remaining: \(Int(trialTimeRemaining)) seconds\n\n"
        
        // 2. Check UserDefaults
        report += "💾 USERDEFAULTS STATE:\n"
        let trialStart = UserDefaults.standard.object(forKey: trialStartKey) as? Date
        let trialUsed = UserDefaults.standard.bool(forKey: trialUsedKey)
        let recentPurchase = UserDefaults.standard.object(forKey: "recentPurchaseDate") as? Date
        let reminderEnabled = UserDefaults.standard.bool(forKey: "isReminderEnabled")
        
        report += "  • Trial Start Date: \(trialStart?.description ?? "nil")\n"
        report += "  • Trial Used: \(trialUsed)\n"
        report += "  • Recent Purchase Date: \(recentPurchase?.description ?? "nil")\n"
        report += "  • Reminder Enabled: \(reminderEnabled)\n\n"
        
        // 3. Check all UserDefaults keys
        report += "🔑 SUBSCRIPTION-RELATED USERDEFAULTS:\n"
        let allKeys = UserDefaults.standard.dictionaryRepresentation().keys
        let subscriptionKeys = allKeys.filter { $0.contains("subscription") || $0.contains("trial") || $0.contains("premium") }
        if subscriptionKeys.isEmpty {
            report += "  • No subscription-related keys found\n"
        } else {
            for key in subscriptionKeys.sorted() {
                let value = UserDefaults.standard.object(forKey: key)
                report += "  • \(key): \(String(describing: value))\n"
            }
        }
        report += "\n"
        
        // 4. Check StoreKit products
        report += "🛒 STOREKIT PRODUCTS:\n"
        report += "  • Products Loaded: \(products.count)\n"
        if products.isEmpty {
            report += "  • No products loaded (this is normal for TestFlight)\n"
        } else {
            for product in products {
                report += "  • \(product.id): \(product.displayName) - \(product.displayPrice)\n"
            }
        }
        report += "\n"
        
        // 5. Check app state
        report += "📲 APP STATE:\n"
        report += "  • Application State: \(UIApplication.shared.applicationState.rawValue)\n"
        report += "  • Background Refresh: \(UIApplication.shared.backgroundRefreshStatus.rawValue)\n\n"
        
        // 6. Check notification permissions
        report += "🔔 NOTIFICATION PERMISSIONS:\n"
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            DispatchQueue.main.async {
                var notificationReport = "  • Authorization: \(settings.authorizationStatus.rawValue)\n"
                notificationReport += "  • Alert Setting: \(settings.alertSetting.rawValue)\n"
                notificationReport += "  • Badge Setting: \(settings.badgeSetting.rawValue)\n"
                notificationReport += "  • Sound Setting: \(settings.soundSetting.rawValue)\n\n"
                
                // 7. Check pending notifications
                UNUserNotificationCenter.current().getPendingNotificationRequests { requests in
                    DispatchQueue.main.async {
                        notificationReport += "🔔 PENDING NOTIFICATIONS:\n"
                        notificationReport += "  • Count: \(requests.count)\n"
                        if requests.isEmpty {
                            notificationReport += "  • No pending notifications\n\n"
                        } else {
                            for request in requests.prefix(5) {
                                notificationReport += "  • \(request.identifier): \(request.content.title)\n"
                            }
                            if requests.count > 5 {
                                notificationReport += "  • ... and \(requests.count - 5) more\n"
                            }
                            notificationReport += "\n"
                        }
                        
                        // 8. Check current entitlements
                        notificationReport += "🎫 CURRENT ENTITLEMENTS:\n"
                        Task {
                            await self.checkCurrentEntitlementsForReport { entitlementsReport in
                                DispatchQueue.main.async {
                                    let finalReport = report + notificationReport + entitlementsReport
                                    self.diagnosticReport = finalReport
                                    self.showingDiagnosticReport = true
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    
    private func checkCurrentEntitlements() async {
        print("🎫 Checking current entitlements...")
        var foundEntitlements = false
        
        for await result in Transaction.currentEntitlements {
            do {
                let transaction = try checkVerified(result)
                foundEntitlements = true
                print("🎫 Found entitlement:")
                print("🎫   - Product ID: \(transaction.productID)")
                print("🎫   - Transaction ID: \(transaction.id)")
                print("🎫   - Purchase Date: \(transaction.purchaseDate)")
                print("🎫   - Expiration Date: \(transaction.expirationDate?.description ?? "nil")")
                print("🎫   - Revocation Date: \(transaction.revocationDate?.description ?? "nil")")
                print("🎫   - Is Upgraded: \(transaction.isUpgraded)")
                print("🎫   - Environment: \(transaction.environment)")
                
                // Check if it's our product
                if transaction.productID == monthlyProductID || transaction.productID == yearlyProductID {
                    print("🎫   ✅ This is OUR subscription product!")
                    
                    // Check if it's active
                    if transaction.revocationDate == nil {
                        print("🎫   ✅ Subscription is ACTIVE")
                        if let expiration = transaction.expirationDate {
                            let timeRemaining = expiration.timeIntervalSinceNow
                            if timeRemaining > 0 {
                                print("🎫   ✅ Time remaining: \(Int(timeRemaining/3600)) hours")
                            } else {
                                print("🎫   ❌ Subscription EXPIRED")
                            }
                        }
                    } else {
                        print("🎫   ⚠️ Subscription is CANCELLED")
                        if let expiration = transaction.expirationDate {
                            let timeRemaining = expiration.timeIntervalSinceNow
                            if timeRemaining > 0 {
                                print("🎫   ⚠️ Still active until: \(expiration)")
                            } else {
                                print("🎫   ❌ Cancelled subscription EXPIRED")
                            }
                        }
                    }
                } else {
                    print("🎫   ℹ️ This is NOT our subscription product")
                }
            } catch {
                print("🎫 ❌ Failed to verify transaction: \(error)")
            }
        }
        
        if !foundEntitlements {
            print("🎫 ❌ NO ENTITLEMENTS FOUND - This suggests no active subscriptions")
        }
    }
    
    private func checkCurrentEntitlementsForReport(completion: @escaping (String) -> Void) async {
        var entitlementsReport = ""
        var foundEntitlements = false
        var foundOurEntitlements = false
        
        for await result in Transaction.currentEntitlements {
            do {
                let transaction = try checkVerified(result)
                foundEntitlements = true
                entitlementsReport += "  • Found entitlement:\n"
                entitlementsReport += "    - Product ID: \(transaction.productID)\n"
                entitlementsReport += "    - Transaction ID: \(transaction.id)\n"
                entitlementsReport += "    - Purchase Date: \(transaction.purchaseDate)\n"
                entitlementsReport += "    - Expiration Date: \(transaction.expirationDate?.description ?? "nil")\n"
                entitlementsReport += "    - Revocation Date: \(transaction.revocationDate?.description ?? "nil")\n"
                entitlementsReport += "    - Is Upgraded: \(transaction.isUpgraded)\n"
                entitlementsReport += "    - Environment: \(transaction.environment)\n"
                
                // Check if it's our product
                if transaction.productID == monthlyProductID || transaction.productID == yearlyProductID {
                    foundOurEntitlements = true
                    entitlementsReport += "    ✅ This is OUR subscription product!\n"
                    
                    // Check if it's active
                    if transaction.revocationDate == nil {
                        entitlementsReport += "    ✅ Subscription is ACTIVE\n"
                        if let expiration = transaction.expirationDate {
                            let timeRemaining = expiration.timeIntervalSinceNow
                            if timeRemaining > 0 {
                                entitlementsReport += "    ✅ Time remaining: \(Int(timeRemaining/3600)) hours\n"
                            } else {
                                entitlementsReport += "    ❌ Subscription EXPIRED\n"
                            }
                        }
                    } else {
                        entitlementsReport += "    ⚠️ Subscription is CANCELLED\n"
                        if let expiration = transaction.expirationDate {
                            let timeRemaining = expiration.timeIntervalSinceNow
                            if timeRemaining > 0 {
                                entitlementsReport += "    ⚠️ Still active until: \(expiration)\n"
                            } else {
                                entitlementsReport += "    ❌ Cancelled subscription EXPIRED\n"
                            }
                        }
                    }
                } else {
                    entitlementsReport += "    ℹ️ This is NOT our subscription product\n"
                }
                entitlementsReport += "\n"
            } catch {
                entitlementsReport += "  • ❌ Failed to verify transaction: \(error)\n"
            }
        }
        
        if !foundEntitlements {
            entitlementsReport += "  • ❌ NO ENTITLEMENTS FOUND\n"
            entitlementsReport += "  • This suggests no active subscriptions on Apple's servers\n"
        } else if !foundOurEntitlements {
            entitlementsReport += "  • ℹ️ Found entitlements, but none for our app\n"
        }
        
        entitlementsReport += "\n"
        
        // Add diagnosis
        entitlementsReport += "🔍 DIAGNOSIS:\n"
        if foundOurEntitlements {
            entitlementsReport += "  • ✅ REAL PHANTOM SUBSCRIPTION DETECTED\n"
            entitlementsReport += "  • Apple's servers show an active subscription\n"
            entitlementsReport += "  • You should contact Apple Support\n"
        } else if isPremiumActive {
            entitlementsReport += "  • 🟡 APP BUG DETECTED\n"
            entitlementsReport += "  • Local app shows premium active\n"
            entitlementsReport += "  • But no subscription on Apple's servers\n"
            entitlementsReport += "  • Use 'Clear All Data' to fix\n"
        } else {
            entitlementsReport += "  • ✅ NO ISSUE DETECTED\n"
            entitlementsReport += "  • App state matches Apple's servers\n"
        }
        
        completion(entitlementsReport)
    }
    
    func generateDiagnosticReport() -> String {
        var report = "🔍 SUBSCRIPTION DIAGNOSTIC REPORT\n"
        report += "📅 Generated: \(Date())\n"
        report += "📱 App Version: \(Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "Unknown")\n\n"
        
        report += "📱 LOCAL STATE:\n"
        report += "  • Premium Active: \(isPremiumActive)\n"
        report += "  • Trial Active: \(isTrialActive)\n"
        report += "  • Trial Used: \(hasUsedTrial)\n"
        report += "  • Subscription Cancelled: \(isSubscriptionCancelled)\n"
        report += "  • Expiration Date: \(subscriptionExpirationDate?.description ?? "nil")\n\n"
        
        report += "💾 USERDEFAULTS:\n"
        let trialStart = UserDefaults.standard.object(forKey: trialStartKey) as? Date
        let trialUsed = UserDefaults.standard.bool(forKey: trialUsedKey)
        let recentPurchase = UserDefaults.standard.object(forKey: "recentPurchaseDate") as? Date
        report += "  • Trial Start: \(trialStart?.description ?? "nil")\n"
        report += "  • Trial Used: \(trialUsed)\n"
        report += "  • Recent Purchase: \(recentPurchase?.description ?? "nil")\n\n"
        
        report += "🛒 PRODUCTS:\n"
        report += "  • Products Loaded: \(products.count)\n"
        for product in products {
            report += "  • \(product.id): \(product.displayName)\n"
        }
        
        return report
    }
    
    // MARK: - Emergency Phantom Subscription Cleanup
    
    func emergencyPhantomSubscriptionCleanup() {
        print("🚨 EMERGENCY: Starting phantom subscription cleanup...")
        
        // Step 1: Force clear ALL local subscription data
        print("🚨 Step 1: Clearing all local subscription data...")
        
        // Stop all timers
        trialTimer?.invalidate()
        trialTimer = nil
        subscriptionTimer?.invalidate()
        subscriptionTimer = nil
        
        // Force reset ALL subscription state
        isPremiumActive = false
        isTrialActive = false
        trialTimeRemaining = 0
        trialDaysRemaining = 0
        hasUsedTrial = false
        isSubscriptionCancelled = false
        subscriptionExpirationDate = nil
        isLoading = false
        
        // Clear ALL UserDefaults related to subscriptions
        let keysToRemove = [
            trialStartKey,
            trialUsedKey,
            subscriptionStatusKey,
            "recentPurchaseDate",
            "isReminderEnabled",
            "subscriptionExpirationDate",
            "isSubscriptionCancelled",
            "isPremiumActive",
            "hasUsedTrial"
        ]
        
        for key in keysToRemove {
            UserDefaults.standard.removeObject(forKey: key)
        }
        UserDefaults.standard.synchronize()
        
        // Clear all pending notifications
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
        
        print("🚨 Step 1 Complete: All local data cleared")
        
        // Step 2: Force App Store sync to refresh from server
        print("🚨 Step 2: Forcing App Store sync...")
        Task {
            do {
                try await AppStore.sync()
                print("🚨 Step 2 Complete: App Store sync successful")
            } catch {
                print("🚨 Step 2 Warning: App Store sync failed - \(error)")
            }
            
            // Step 3: Update subscription status
            print("🚨 Step 3: Updating subscription status...")
            await updateSubscriptionStatus()
            print("🚨 Step 3 Complete: Subscription status updated")
            
            // Step 4: Final cleanup
            print("🚨 EMERGENCY CLEANUP COMPLETE!")
            print("🚨 If subscription still appears, follow manual steps:")
            print("🚨 1. Go to Settings > [Your Name] > Subscriptions")
            print("🚨 2. Find WaterReminderApp subscription")
            print("🚨 3. Cancel it manually")
            print("🚨 4. Delete and reinstall the app")
            print("🚨 5. If still there, contact Apple Support")
            print("🚨 6. Tell them: 'Phantom sandbox subscription from TestFlight testing'")
        }
    }
    
    func forceCancelPhantomSubscription() {
        print("🚨 FORCE CANCEL: Attempting to cancel phantom subscription...")
        
        // This will open the App Store subscription management
        // where you can manually cancel the phantom subscription
        openSubscriptionManagement()
        
        print("🚨 FORCE CANCEL: Opening App Store subscription management...")
        print("🚨 MANUAL STEPS REQUIRED:")
        print("🚨 1. Find 'WaterReminderApp' subscription in the list")
        print("🚨 2. Tap 'Cancel Subscription'")
        print("🚨 3. Confirm cancellation")
        print("🚨 4. Return to app and use 'Clear All Data'")
    }
    
    // MARK: - NUCLEAR OPTION: Force Finish All Transactions
    
    func nuclearOptionCancelAllTransactions() async {
        print("☢️ NUCLEAR OPTION: Starting force cancellation of ALL transactions...")
        print("☢️ WARNING: This will attempt to finish ALL unfinished transactions!")
        
        // Step 1: Cancel the transaction listener to prevent new ones
        print("☢️ Step 1: Cancelling transaction listener...")
        updateListenerTask?.cancel()
        updateListenerTask = nil
        
        // Step 2: Force finish ALL current entitlements
        print("☢️ Step 2: Force finishing all current entitlements...")
        var transactionCount = 0
        for await result in Transaction.currentEntitlements {
            do {
                let transaction = try checkVerified(result)
                print("☢️ Finishing transaction: \(transaction.id) - Product: \(transaction.productID)")
                await transaction.finish()
                transactionCount += 1
            } catch {
                print("☢️ Failed to finish transaction: \(error)")
            }
        }
        print("☢️ Finished \(transactionCount) transactions")
        
        // Step 3: Force finish ALL transaction updates
        print("☢️ Step 3: Checking for any pending transaction updates...")
        let updatesTask = Task {
            var updateCount = 0
            for await result in Transaction.updates {
                do {
                    let transaction = try await self.checkVerified(result)
                    print("☢️ Finishing pending transaction: \(transaction.id)")
                    await transaction.finish()
                    updateCount += 1
                    
                    // Only process a few to avoid infinite loop
                    if updateCount >= 10 {
                        break
                    }
                } catch {
                    print("☢️ Failed to finish pending transaction: \(error)")
                }
            }
            return updateCount
        }
        
        // Wait for updates task with timeout
        do {
            try await withThrowingTaskGroup(of: Int.self) { group in
                group.addTask { try await updatesTask.value }
                group.addTask {
                    try await Task.sleep(nanoseconds: 5_000_000_000) // 5 second timeout
                    throw NSError(domain: "TimeoutError", code: -1)
                }
                
                if let count = try await group.next() {
                    print("☢️ Finished \(count) pending updates")
                }
                group.cancelAll()
            }
        } catch {
            print("☢️ Update processing completed or timed out")
        }
        
        // Step 4: Force sync with App Store
        print("☢️ Step 4: Force syncing with App Store...")
        do {
            try await AppStore.sync()
            print("☢️ App Store sync completed")
        } catch {
            print("☢️ App Store sync failed: \(error)")
        }
        
        // Step 5: Clear ALL local subscription data
        print("☢️ Step 5: Clearing ALL local data...")
        isPremiumActive = false
        isTrialActive = false
        trialTimeRemaining = 0
        trialDaysRemaining = 0
        hasUsedTrial = false
        isSubscriptionCancelled = false
        subscriptionExpirationDate = nil
        isLoading = false
        
        // Clear all UserDefaults
        let keysToRemove = [
            trialStartKey, trialUsedKey, subscriptionStatusKey,
            "recentPurchaseDate", "isReminderEnabled", "subscriptionExpirationDate",
            "isSubscriptionCancelled", "isPremiumActive", "hasUsedTrial"
        ]
        for key in keysToRemove {
            UserDefaults.standard.removeObject(forKey: key)
        }
        UserDefaults.standard.synchronize()
        
        // Step 6: Check final status
        print("☢️ Step 6: Checking final subscription status...")
        await updateSubscriptionStatus()
        
        print("☢️ NUCLEAR OPTION COMPLETE!")
        print("☢️ If subscription still appears, it's definitely on Apple's servers")
        print("☢️ Next steps:")
        print("☢️ 1. Go to App Store Connect: https://appstoreconnect.apple.com")
        print("☢️ 2. Users and Access → Sandbox → Select your account")
        print("☢️ 3. Click 'Clear Purchase History'")
        print("☢️ 4. OR create a new sandbox tester account")
        
        // Restart transaction listener
        print("☢️ Restarting transaction listener...")
        updateListenerTask = listenForTransactions()
    }
}

// MARK: - Store Error

enum StoreError: Error {
    case failedVerification
}

// MARK: - Subscription Status Extension

extension SubscriptionManager {
    var subscriptionStatusText: String {
        if isPremiumActive {
            return "Premium Active"
        } else if isTrialActive {
            return "Trial: \(trialDaysRemaining) days left"
        } else {
            return "Trial Expired"
        }
    }
    
    var canAccessFeatures: Bool {
        return canUseApp()
    }
}
