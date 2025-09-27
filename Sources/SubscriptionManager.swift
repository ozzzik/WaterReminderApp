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
            return
        }
        
        let trialDuration = TimeInterval(trialDurationDays * 24 * 60 * 60) // 7 days in seconds
        let timeElapsed = Date().timeIntervalSince(trialStart)
        let timeRemaining = trialDuration - timeElapsed
        
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
        let result = try await product.purchase()
        
        switch result {
        case .success(let verification):
            let transaction = try checkVerified(verification)
            await transaction.finish()
            checkSubscriptionStatus()
            return transaction
            
        case .userCancelled, .pending:
            return nil
            
        default:
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
        
        for await result in Transaction.currentEntitlements {
            do {
                let transaction = try checkVerified(result)
                
                if transaction.productID == monthlyProductID || transaction.productID == yearlyProductID {
                    if transaction.revocationDate == nil {
                        isActive = true
                        break
                    }
                }
            } catch {
                print("❌ Failed to verify transaction: \(error)")
            }
        }
        
        await MainActor.run {
            isPremiumActive = isActive
            print("💳 Subscription status: \(isActive ? "Active" : "Inactive")")
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
        checkTrialStatus()
        print("🧪 DEBUG: Simulated trial end")
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
