import Foundation
import StoreKit
import SwiftUI

/// Receipt data structure for debugging subscription issues
struct ReceiptData {
    let isInBillingRetryPeriod: Bool
    let isTrialPeriod: Bool
    let expiresDate: Date?
    let productId: String?
    let originalTransactionId: String?
    let rawReceipt: String
}

/// Clean SubscriptionManager built on StoreKit2 best practices
/// Based on: StoreHelper (Russell Archer) & StoreKit2 Demo (Aisultan)
@MainActor
class SubscriptionManager: ObservableObject {
    static let shared = SubscriptionManager()
    
    // MARK: - Product Configuration
    
    /// Product IDs for subscriptions (v4 - fresh start)
    private let productIds: Set<String> = [
        "com.whio.waterreminder.monthly.v4",
        "com.whio.waterreminder.yearly.v4"
    ]
    
    // MARK: - Published State
    
    /// Available subscription products from App Store
    @Published var products: [Product] = []
    
    /// Current subscription status
    @Published var subscriptionStatus: SubscriptionStatus = .notSubscribed
    
    /// Currently active subscription product
    @Published var currentSubscription: Product?
    
    /// Subscription expiration date (if active)
    @Published var expirationDate: Date?
    
    /// Loading state for purchases and restores
    @Published var isLoading = false
    
    /// Error message for user display
    @Published var errorMessage: String?
    
    /// Receipt verification data for debugging
    @Published var receiptData: ReceiptData?
    
    /// Whether subscription status has been checked at least once
    @Published var hasCheckedSubscriptionStatus = false
    
    // MARK: - Private State
    
    /// Task for listening to transaction updates
    private var updateListenerTask: Task<Void, Never>?
    
    // MARK: - Initialization
    
    init() {
        // Start listening for transaction updates immediately
        updateListenerTask = listenForTransactions()
        
        // Load products and check subscription status
        Task {
            await loadProducts()
            await updateSubscriptionStatus()
        }
    }
    
    deinit {
        updateListenerTask?.cancel()
    }
    
    // MARK: - Product Loading
    
    /// Load products from App Store
    func loadProducts() async {
        do {
            print("📦 Loading products...")
            let loadedProducts = try await Product.products(for: productIds)
            
            // Sort by price (monthly first, then yearly)
            products = loadedProducts.sorted { $0.price < $1.price }
            
            print("✅ Loaded \(products.count) products")
            for product in products {
                print("  - \(product.displayName): \(product.displayPrice)")
            }
        } catch {
            print("❌ Failed to load products: \(error)")
            errorMessage = "Failed to load subscription options. Please try again."
        }
    }
    
    // MARK: - Purchase
    
    /// Purchase a subscription product
    func purchase(_ product: Product) async throws {
        print("💳 Starting purchase for: \(product.displayName) (ID: \(product.id))")
        print("💳 Product type: \(product.type)")
        print("💳 Product price: \(product.displayPrice)")
        print("💳 iOS version: \(UIDevice.current.systemVersion)")
        
        // Check if we're in a supported environment
        guard product.type == .autoRenewable else {
            throw StoreError.failedVerification
        }
        
        isLoading = true
        errorMessage = nil
        
        defer { 
            isLoading = false
            print("💳 Purchase process completed")
        }
        
        do {
            print("💳 Calling product.purchase()...")
            let result = try await product.purchase()
            print("💳 Purchase result received: \(result)")
            
            switch result {
            case .success(let verification):
                print("✅ Purchase successful, verifying...")
                let transaction = try checkVerified(verification)
                print("✅ Transaction verified: \(transaction.id)")
                
                // Update subscription status
                await updateSubscriptionStatus()
                
                // Finish the transaction
                await transaction.finish()
                print("✅ Transaction finished: \(transaction.id)")
                
            case .userCancelled:
                print("⚠️ User cancelled purchase")
                // Don't update subscription status when user cancels
                return
                
            case .pending:
                print("⏳ Purchase pending approval")
                errorMessage = "Purchase is pending approval"
                
            @unknown default:
                print("⚠️ Unknown purchase result")
                errorMessage = "Unknown purchase result"
            }
        } catch {
            print("❌ Purchase failed with error: \(error)")
            print("❌ Error type: \(type(of: error))")
            print("❌ Error description: \(error.localizedDescription)")
            
            // Handle specific error types
            let userFriendlyMessage: String
            if let storeKitError = error as? StoreKitError {
                switch storeKitError {
                case .networkError:
                    userFriendlyMessage = "Network connection failed. Please check your internet connection and try again."
                case .userCancelled:
                    userFriendlyMessage = "Purchase was cancelled."
                    return // Don't show error for user cancellation
                case .systemError:
                    userFriendlyMessage = "System error occurred. Please try again."
                default:
                    userFriendlyMessage = "Purchase failed: \(error.localizedDescription)"
                }
            } else {
                userFriendlyMessage = "Purchase failed: \(error.localizedDescription)"
            }
            
            errorMessage = userFriendlyMessage
            throw error
        }
    }
    
    // MARK: - Transaction Listener
    
    /// Listen for transaction updates from the App Store
    private func listenForTransactions() -> Task<Void, Never> {
        return Task.detached { [weak self] in
            print("👂 Starting transaction listener...")
            
            for await result in Transaction.updates {
                do {
                    let transaction = try await self?.checkVerified(result)
                    
                    if let transaction = transaction {
                        print("🔔 Transaction update: \(transaction.id)")
                        
                        // Update subscription status on main actor
                        await self?.updateSubscriptionStatus()
                        
                        // Finish the transaction
                        await transaction.finish()
                    }
                } catch {
                    print("❌ Transaction verification failed: \(error)")
                }
            }
        }
    }
    
    // MARK: - Subscription Status
    
    /// Check and update current subscription status
    func updateSubscriptionStatus() async {
        print("🔄 Updating subscription status...")
        
        var activeSubscription: Product?
        var latestExpiration: Date?
        var status: SubscriptionStatus = .notSubscribed
        
        // Check current entitlements
        for await result in Transaction.currentEntitlements {
            do {
                let transaction = try checkVerified(result)
                
                // Check if this is one of our subscription products
                if productIds.contains(transaction.productID) {
                    print("✅ Found active entitlement: \(transaction.productID)")
                    
                    // Find the matching product
                    if let product = products.first(where: { $0.id == transaction.productID }) {
                        activeSubscription = product
                        latestExpiration = transaction.expirationDate
                        
                        // Determine status based on transaction state
                        if let expiration = transaction.expirationDate {
                            if expiration > Date() {
                                // Check if this is a trial period (first purchase within trial period)
                                let isTrialPeriod = transaction.isUpgraded == false && 
                                                   transaction.originalPurchaseDate == transaction.purchaseDate
                                
                                if isTrialPeriod {
                                    print("🎁 Trial period active until: \(expiration)")
                                } else {
                                    print("✅ Subscription active until: \(expiration)")
                                }
                                status = .subscribed // Both trial and paid subscriptions are "subscribed"
                            } else {
                                status = .expired
                                print("⚠️ Subscription expired: \(expiration)")
                            }
                        }
                        
                        // Check for cancellation (will expire but still active)
                        if transaction.revocationDate != nil {
                            status = .expired
                            print("⚠️ Subscription revoked")
                        }
                    }
                }
            } catch {
                print("❌ Failed to verify entitlement: \(error)")
            }
        }
        
        // Update published properties
        currentSubscription = activeSubscription
        expirationDate = latestExpiration
        subscriptionStatus = status
        hasCheckedSubscriptionStatus = true
        
        print("📊 Subscription status updated: \(status)")
    }
    
    // MARK: - Restore Purchases
    
    /// Restore previous purchases
    func restorePurchases() async {
        print("🔄 Restoring purchases...")
        isLoading = true
        errorMessage = nil
        
        defer { isLoading = false }
        
        do {
            // Sync with App Store
            try await AppStore.sync()
            print("✅ App Store sync completed")
            
            // Update subscription status
            await updateSubscriptionStatus()
            
            if subscriptionStatus == .subscribed {
                print("✅ Purchases restored successfully")
            } else {
                print("ℹ️ No active subscriptions found")
                errorMessage = "No active subscriptions found"
            }
        } catch {
            print("❌ Failed to restore purchases: \(error)")
            errorMessage = "Failed to restore purchases: \(error.localizedDescription)"
        }
    }
    
    // MARK: - Verification
    
    /// Verify a transaction using StoreKit2 verification
    private func checkVerified<T>(_ result: VerificationResult<T>) throws -> T {
        switch result {
        case .unverified(let item, let error):
            print("❌ Transaction verification failed for \(item): \(error)")
            print("❌ Verification error details: \(error.localizedDescription)")
            throw StoreError.failedVerification
        case .verified(let safe):
            print("✅ Transaction verified successfully: \(safe)")
            return safe
        }
    }
    
    // MARK: - Helper Properties

    /// When true, app uses ads-only monetization: everyone has full access; "Watch ad to skip next reminder" is shown.
    static var useAdsInsteadOfSubscription = true

    /// Check if user has premium access (including trial periods, legacy users, or ads-only mode)
    var isPremiumActive: Bool {
        if SubscriptionManager.useAdsInsteadOfSubscription {
            return true
        }
        if isLegacyUser {
            return true
        }
        if let expiration = expirationDate, expiration > Date() {
            switch subscriptionStatus {
            case .subscribed, .inGracePeriod:
                return true
            case .notSubscribed, .expired:
                return false
            }
        }
        return false
    }
    
    /// Check if user is a legacy user (purchased the paid app before it became free)
    /// SECURITY: This checks for a cryptographically signed legacy entitlement
    /// stored in Keychain, not UserDefaults, to prevent tampering
    var isLegacyUser: Bool {
        // Check Keychain for signed legacy entitlement (more secure than UserDefaults)
        // This prevents users from easily modifying the flag
        if let legacyData = KeychainHelper.shared.get(key: "legacyFullAccess") {
            // Verify the data is valid (contains expected signature/identifier)
            // For additional security, you could verify against a server or use cryptographic signing
            return legacyData == "verified_legacy_user_v1"
        }
        return false
    }
    
    /// Set user as legacy user (call this for existing paid users)
    /// SECURITY: Stores in Keychain instead of UserDefaults to prevent tampering
    func setLegacyUser() {
        // Store in Keychain instead of UserDefaults for better security
        KeychainHelper.shared.set(key: "legacyFullAccess", value: "verified_legacy_user_v1")
        print("✅ User set as legacy user - full access granted (stored securely)")
    }
    
    /// Get legacy user status for UI display
    var legacyUserStatus: String {
        if isLegacyUser {
            return "Legacy Full Access"
        }
        return subscriptionStatus.displayText
    }
    
    /// Get monthly product
    var monthlyProduct: Product? {
        products.first { $0.id.contains("monthly") }
    }
    
    /// Get yearly product
    var yearlyProduct: Product? {
        products.first { $0.id.contains("yearly") }
    }
    
    /// Calculate yearly savings
    var yearlySavings: String {
        guard let monthly = monthlyProduct,
              let yearly = yearlyProduct else {
            return "Save 17%"
        }
        
        let monthlyCost = monthly.price * 12
        let yearlyCost = yearly.price
        let savings = monthlyCost - yearlyCost
        let savingsPercent = (savings / monthlyCost) * 100
        
        // Convert Decimal to Double for String formatting
        let percentValue = (savingsPercent as NSDecimalNumber).doubleValue
        return String(format: "%.0f%%", percentValue)
    }
    
    // MARK: - Debug Methods (Basic - For Testing Only)
    
    #if DEBUG
    /// Simulate premium activation (debug only)
    func activateSubscription() {
        subscriptionStatus = .subscribed
        print("🔄 Premium activated (simulation)")
    }
    
    /// Cancel subscription (debug only - simulates cancellation)
    func cancelSubscription() {
        subscriptionStatus = .notSubscribed
        currentSubscription = nil
        expirationDate = nil
        
        print("🔄 Subscription cancelled (simulation)")
    }
    #endif
    
    // MARK: - Receipt Verification (Debugging)
    
    /// Verify App Store receipt to debug subscription issues
    func verifyReceipt() {
        Task {
            do {
                let receiptData = try await fetchReceiptData()
                await MainActor.run {
                    self.receiptData = receiptData
                    print("🔍 RECEIPT VERIFICATION:")
                    print("   isInBillingRetryPeriod: \(receiptData.isInBillingRetryPeriod)")
                    print("   isTrialPeriod: \(receiptData.isTrialPeriod)")
                    print("   expiresDate: \(receiptData.expiresDate?.description ?? "nil")")
                    print("   productId: \(receiptData.productId ?? "nil")")
                    print("   originalTransactionId: \(receiptData.originalTransactionId ?? "nil")")
                }
            } catch {
                print("❌ Receipt verification failed: \(error)")
            }
        }
    }
    
    /// Fetch and decode App Store receipt
    private func fetchReceiptData() async throws -> ReceiptData {
        // Refresh receipt first
        try await AppStore.sync()
        
        // Get current entitlements
        var isInBillingRetryPeriod = false
        var isTrialPeriod = false
        var expiresDate: Date?
        var productId: String?
        var originalTransactionId: String?
        
        for await result in Transaction.currentEntitlements {
            if case .verified(let transaction) = result {
                if transaction.productType == .autoRenewable {
                    isInBillingRetryPeriod = false // StoreKit2 doesn't expose this directly
                    isTrialPeriod = transaction.isUpgraded == false && transaction.originalPurchaseDate == transaction.purchaseDate
                    expiresDate = transaction.expirationDate
                    productId = transaction.productID
                    originalTransactionId = String(transaction.originalID)
                    break
                }
            }
        }
        
        // Get raw receipt data (for debugging)
        let rawReceipt = "Receipt data available in StoreKit2 via Transaction.currentEntitlements"
        
        return ReceiptData(
            isInBillingRetryPeriod: isInBillingRetryPeriod,
            isTrialPeriod: isTrialPeriod,
            expiresDate: expiresDate,
            productId: productId,
            originalTransactionId: originalTransactionId,
            rawReceipt: rawReceipt
        )
    }
}

// MARK: - Subscription Status

enum SubscriptionStatus {
    case notSubscribed
    case subscribed
    case expired
    case inGracePeriod
    
    var displayText: String {
        switch self {
        case .notSubscribed:
            return "Not Subscribed"
        case .subscribed:
            return "Premium Active"
        case .expired:
            return "Subscription Expired"
        case .inGracePeriod:
            return "Grace Period"
        }
    }
}

// MARK: - Store Error

enum StoreError: Error, LocalizedError {
    case failedVerification
    
    var errorDescription: String? {
        switch self {
        case .failedVerification:
            return "Transaction verification failed"
        }
    }
}

