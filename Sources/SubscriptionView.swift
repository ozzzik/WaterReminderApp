import SwiftUI
import StoreKit

struct SubscriptionView: View {
    @EnvironmentObject var subscriptionManager: SubscriptionManager
    @Environment(\.dismiss) private var dismiss
    
    @State private var selectedProduct: Product?
    @State private var showingPurchaseAlert = false
    @State private var purchaseMessage = ""
    
    /// Dynamic message based on subscription status
    private var subscriptionMessage: String {
        switch subscriptionManager.subscriptionStatus {
        case .notSubscribed:
            return "Start your free trial and unlock all premium features for tracking your daily water intake."
        case .expired:
            return "Your free trial has ended. Subscribe to keep tracking your daily water intake."
        case .inGracePeriod:
            return "Your subscription is in grace period. Subscribe to continue enjoying premium features."
        case .subscribed:
            return "You're already subscribed! Thank you for supporting the app."
        }
    }
    
    /// Dynamic button text based on subscription status
    private var buttonText: String {
        switch subscriptionManager.subscriptionStatus {
        case .notSubscribed:
            return "Start Free Trial"
        case .expired:
            return "Subscribe Now"
        case .inGracePeriod:
            return "Renew Subscription"
        case .subscribed:
            return "Manage Subscription"
        }
    }
    
    var body: some View {
        GeometryReader { geometry in
            VStack(spacing: 0) {
                // Scrollable content
                ScrollView {
                    VStack(spacing: 24) {
                        // Header
                        VStack(spacing: 16) {
                            Image(systemName: "drop.fill")
                                .font(.system(size: 60))
                                .foregroundColor(.blue)
                            
                            Text("Continue Your Hydration Journey")
                                .font(.title)
                                .fontWeight(.bold)
                                .multilineTextAlignment(.center)
                            
                            Text(subscriptionMessage)
                                .font(.body)
                                .foregroundColor(.secondary)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal)
                        }
                        .padding(.top, 20)
                        .padding(.bottom, 20)
                        
                        // Subscription Options
                        VStack(spacing: 16) {
                            // Yearly Option (Recommended)
                            if let yearlyProduct = subscriptionManager.yearlyProduct {
                                SubscriptionOptionView(
                                    product: yearlyProduct,
                                    isRecommended: true,
                                    isSelected: selectedProduct?.id == yearlyProduct.id,
                                    savingsText: subscriptionManager.yearlySavings
                                ) {
                                    selectedProduct = yearlyProduct
                                }
                            }
                            
                            // Monthly Option
                            if let monthlyProduct = subscriptionManager.monthlyProduct {
                                SubscriptionOptionView(
                                    product: monthlyProduct,
                                    isRecommended: false,
                                    isSelected: selectedProduct?.id == monthlyProduct.id,
                                    savingsText: nil
                                ) {
                                    selectedProduct = monthlyProduct
                                }
                            }
                        }
                        .padding(.horizontal, max(20, geometry.size.width * 0.1))
                    }
                }
                
                // Fixed bottom section for pricing and CTA
                VStack(spacing: 16) {
                    Divider()
                    
                    Button(action: purchaseSubscription) {
                        HStack {
                            if subscriptionManager.isLoading {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                    .scaleEffect(0.8)
                            } else {
                                Text(buttonText)
                                    .fontWeight(.semibold)
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .frame(height: 50)
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(12)
                    }
                    .disabled(subscriptionManager.isLoading || selectedProduct == nil)
                    .padding(.horizontal, max(20, geometry.size.width * 0.1))
                    
                    // Restore Purchases
                    Button("Restore Purchases") {
                        Task {
                            await subscriptionManager.restorePurchases()
                        }
                    }
                    .font(.subheadline)
                    .foregroundColor(.blue)
                    .disabled(subscriptionManager.isLoading)
                    
                    // Terms and Privacy Policy Links
                    VStack(spacing: 8) {
                        HStack(spacing: 16) {
                            Link("Privacy Policy", destination: URL(string: "https://ozzzik.github.io/WaterReminderApp/privacy-policy.html")!)
                                .font(.caption2)
                                .foregroundColor(.blue)
                            
                            Text("•")
                                .font(.caption2)
                                .foregroundColor(.secondary)
                            
                            Link("Terms of Use (EULA)", destination: URL(string: "https://www.apple.com/legal/internet-services/itunes/dev/stdeula/")!)
                                .font(.caption2)
                                .foregroundColor(.blue)
                        }
                        
                        Text("Cancel anytime. Subscription automatically renews unless auto-renew is turned off at least 24 hours before the end of the current period.")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                    }
                    .padding(.horizontal, max(20, geometry.size.width * 0.1))
                    .padding(.bottom, 20)
                }
                .background(Color(.systemBackground))
            }
            .task {
                print("🔄 Loading subscription products...")
                await subscriptionManager.loadProducts()
                
                // Auto-select yearly product if available
                if let yearlyProduct = subscriptionManager.yearlyProduct {
                    print("✅ Auto-selected yearly product: \(yearlyProduct.id)")
                    selectedProduct = yearlyProduct
                } else if let monthlyProduct = subscriptionManager.monthlyProduct {
                    print("✅ Auto-selected monthly product: \(monthlyProduct.id)")
                    selectedProduct = monthlyProduct
                } else {
                    print("⚠️ No products available for selection")
                }
            }
            .alert("Purchase Result", isPresented: $showingPurchaseAlert) {
                Button("OK") { }
            } message: {
                Text(purchaseMessage)
            }
        }
    }
    
    private func purchaseSubscription() {
        guard let product = selectedProduct else { 
            purchaseMessage = "Please select a subscription option"
            showingPurchaseAlert = true
            return 
        }
        
        // Check if already loading
        guard !subscriptionManager.isLoading else {
            purchaseMessage = "Purchase already in progress. Please wait..."
            showingPurchaseAlert = true
            return
        }
        
        Task {
            do {
                print("🛒 Starting purchase for product: \(product.id)")
                try await subscriptionManager.purchase(product)
                
                print("✅ Purchase completed successfully")
                purchaseMessage = "Subscription activated successfully!"
                showingPurchaseAlert = true
                
                // Wait for subscription status to update, then dismiss
                DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                    if subscriptionManager.isPremiumActive {
                        dismiss()
                    }
                }
            } catch {
                let errorMessage = error.localizedDescription
                print("❌ Purchase error: \(errorMessage)")
                
                // Don't show error for user cancellation
                if !errorMessage.lowercased().contains("cancelled") {
                    purchaseMessage = "Purchase failed: \(errorMessage)"
                    showingPurchaseAlert = true
                }
            }
        }
    }
}

struct SubscriptionOptionView: View {
    let product: Product
    let isRecommended: Bool
    let isSelected: Bool
    let savingsText: String?
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 12) {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        HStack {
                            Text(product.displayName)
                                .font(.headline)
                                .fontWeight(.semibold)
                            
                            if isRecommended {
                                Text("BEST VALUE")
                                    .font(.caption2)
                                    .fontWeight(.bold)
                                    .foregroundColor(.white)
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 2)
                                    .background(Color.orange)
                                    .cornerRadius(4)
                            }
                        }
                        
                        Text(formatPrice(product.price))
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.primary)
                        
                        if let savingsText = savingsText {
                            Text("Save \(savingsText)")
                                .font(.caption)
                                .foregroundColor(.green)
                                .fontWeight(.medium)
                        }
                    }
                    
                    Spacer()
                    
                    // Selection indicator
                    Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                        .font(.title2)
                        .foregroundColor(isSelected ? .blue : .gray)
                }
                .padding(16)
            }
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color(.systemGray6))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(isSelected ? Color.blue : Color.clear, lineWidth: 2)
                    )
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    private func formatPrice(_ price: Decimal) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.locale = Locale.current
        
        if product.id.contains("yearly") {
            return "\(formatter.string(from: price as NSDecimalNumber) ?? "")/year"
        } else {
            return "\(formatter.string(from: price as NSDecimalNumber) ?? "")/month"
        }
    }
}

#Preview {
    SubscriptionView()
        .environmentObject(SubscriptionManager.shared)
}