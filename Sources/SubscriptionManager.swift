import Foundation
import StoreKit
import SwiftUI

@MainActor
class SubscriptionManager: ObservableObject {
    static let shared = SubscriptionManager()
    
    // Subscription product IDs
    private let monthlyProductID = "com.whio.waterreminder.monthly"
    private let yearlyProductID = "com.whio.waterreminder.yearly"
    
    // Trial settings
    private let trialDurationDays = 7
    private let trialStartKey = "trialStartDate"
    private let subscriptionStatusKey = "subscriptionStatus"
    
    @Published var isPremiumActive = false
    @Published var isTrialActive = false
    @Published var trialDaysRemaining = 0
    @Published var isLoading = false
    @Published var products: [Product] = []
    
    private var updateListenerTask: Task<Void, Error>? = nil
    
    private init() {
        // Start listening for transaction updates
        updateListenerTask = listenForTransactions()
        
        // Initialize subscription status
        checkSubscriptionStatus()
        checkTrialStatus()
    }
    
    deinit {
        updateListenerTask?.cancel()
    }
    
    // MARK: - Trial Management
    
    func startTrial() {
        let trialStart = Date()
        UserDefaults.standard.set(trialStart, forKey: trialStartKey)
        checkTrialStatus()
        print("🆓 Trial started: \(trialStart)")
    }
    
    func checkTrialStatus() {
        guard let trialStart = UserDefaults.standard.object(forKey: trialStartKey) as? Date else {
            // No trial started yet
            isTrialActive = false
            trialDaysRemaining = 0
            print("🆓 No trial started yet")
            return
        }
        
        let trialDuration = TimeInterval(trialDurationDays * 24 * 60 * 60) // 7 days in seconds
        let timeElapsed = Date().timeIntervalSince(trialStart)
        let timeRemaining = trialDuration - timeElapsed
        
        print("🆓 Trial check - Start: \(trialStart), Elapsed: \(timeElapsed/86400) days, Remaining: \(timeRemaining/86400) days")
        
        if timeRemaining > 0 {
            isTrialActive = true
            trialDaysRemaining = max(1, Int(ceil(timeRemaining / (24 * 60 * 60))))
            print("🆓 Trial active: \(trialDaysRemaining) days remaining")
        } else {
            isTrialActive = false
            trialDaysRemaining = 0
            print("🆓 Trial expired")
        }
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
            products = try await Product.products(for: productIDs)
            print("🛒 Loaded \(products.count) products")
        } catch {
            print("❌ Failed to load products: \(error)")
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
            await transaction.finish()
            print("✅ Transaction finished")
            
            // Save recent purchase date as fallback for testing
            UserDefaults.standard.set(Date(), forKey: "recentPurchaseDate")
            
            // Force subscription status update
            await updateSubscriptionStatus()
            print("💳 Updated subscription status: \(isPremiumActive)")
            
            // Double-check after a small delay
            try await Task.sleep(nanoseconds: 1_000_000_000) // 1 second
            await updateSubscriptionStatus()
            print("💳 Final subscription status after delay: \(isPremiumActive)")
            
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
        do {
            try await AppStore.sync()
            checkSubscriptionStatus()
            print("🔄 Purchases restored")
        } catch {
            print("❌ Failed to restore purchases: \(error)")
        }
    }
    
    // MARK: - Subscription Status
    
    func checkSubscriptionStatus() {
        Task {
            await updateSubscriptionStatus()
        }
    }
    
    private func updateSubscriptionStatus() async {
        var isActive = false
        
        print("🔍 Checking subscription status...")
        
        // Check current entitlements
        for await result in Transaction.currentEntitlements {
            do {
                let transaction = try checkVerified(result)
                print("🔍 Found entitlement: \(transaction.productID)")
                
                if transaction.productID == monthlyProductID || transaction.productID == yearlyProductID {
                    if transaction.revocationDate == nil {
                        print("✅ Active subscription found: \(transaction.productID)")
                        isActive = true
                        break
                    } else {
                        print("❌ Subscription revoked: \(transaction.productID)")
                    }
                }
            } catch {
                print("❌ Failed to verify transaction: \(error)")
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
        
        await MainActor.run {
            isPremiumActive = isActive
            print("💳 Final subscription status: \(isActive ? "Active" : "Inactive")")
        }
    }
    
    // MARK: - Helper Methods
    
    private func listenForTransactions() -> Task<Void, Error> {
        return Task.detached {
            for await result in Transaction.updates {
                do {
                    let transaction = try await self.checkVerified(result)
                    await transaction.finish()
                    await self.checkSubscriptionStatus()
                } catch {
                    print("❌ Transaction verification failed: \(error)")
                }
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
    
    #if DEBUG
    func simulateTrialEnd() {
        // Set trial start date to 8 days ago
        let eightDaysAgo = Date().addingTimeInterval(-8 * 24 * 60 * 60)
        UserDefaults.standard.set(eightDaysAgo, forKey: trialStartKey)
        print("🧪 DEBUG: Set trial start to 8 days ago: \(eightDaysAgo)")
        checkTrialStatus()
        print("🧪 DEBUG: After trial end simulation - isTrialActive: \(isTrialActive), trialDaysRemaining: \(trialDaysRemaining)")
    }
    
    func simulatePremiumActivation() {
        isPremiumActive = true
        print("🧪 DEBUG: Simulated premium activation")
    }
    
    func simulatePremiumDeactivation() {
        isPremiumActive = false
        print("🧪 DEBUG: Simulated premium deactivation")
    }
    
    func resetTrial() {
        UserDefaults.standard.removeObject(forKey: trialStartKey)
        checkTrialStatus()
        print("🧪 DEBUG: Reset trial")
    }
    
    func clearRecentPurchase() {
        UserDefaults.standard.removeObject(forKey: "recentPurchaseDate")
        checkSubscriptionStatus()
        print("🧪 DEBUG: Cleared recent purchase fallback")
    }
    
    func forceSubscriptionCheck() {
        Task {
            await updateSubscriptionStatus()
            print("🧪 DEBUG: Forced subscription status check - Result: \(isPremiumActive)")
        }
    }
    #endif
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
