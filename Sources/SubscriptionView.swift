import SwiftUI
import StoreKit

struct SubscriptionView: View {
    @ObservedObject private var subscriptionManager = SubscriptionManager.shared
    @Environment(\.dismiss) private var dismiss
    
    @State private var selectedProduct: Product?
    @State private var showingPurchaseAlert = false
    @State private var purchaseMessage = ""
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Header
                VStack(spacing: 16) {
                    Image(systemName: "drop.fill")
                        .font(.system(size: 60))
                        .foregroundColor(.blue)
                    
                    Text("Continue Your Hydration Journey")
                        .font(.title)
                        .fontWeight(.bold)
                        .multilineTextAlignment(.center)
                    
                    Text("Your free trial has ended. Subscribe to keep tracking your daily water intake.")
                        .font(.body)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                }
                .padding(.top, 40)
                .padding(.bottom, 30)
                
                // Subscription Options
                VStack(spacing: 16) {
                    // Yearly Option (Recommended)
                    if let yearlyProduct = subscriptionManager.getYearlyProduct() {
                        SubscriptionOptionView(
                            product: yearlyProduct,
                            isRecommended: true,
                            isSelected: selectedProduct?.id == yearlyProduct.id,
                            savingsText: subscriptionManager.getYearlySavings()
                        ) {
                            selectedProduct = yearlyProduct
                        }
                    }
                    
                    // Monthly Option
                    if let monthlyProduct = subscriptionManager.getMonthlyProduct() {
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
                .padding(.horizontal, 20)
                
                Spacer()
                
                // Purchase Button
                VStack(spacing: 16) {
                    Button(action: purchaseSubscription) {
                        HStack {
                            if subscriptionManager.isLoading {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                    .scaleEffect(0.8)
                            } else {
                                Text("Start Subscription")
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
                    .padding(.horizontal, 20)
                    
                    // Restore Purchases
                    Button("Restore Purchases") {
                        Task {
                            await subscriptionManager.restorePurchases()
                        }
                    }
                    .font(.caption)
                    .foregroundColor(.blue)
                    
                    // Terms and Privacy
                    VStack(spacing: 4) {
                        Text("By subscribing, you agree to our Terms of Service and Privacy Policy.")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                        
                        Text("Cancel anytime. Subscription automatically renews unless auto-renew is turned off at least 24 hours before the end of the current period.")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 20)
                }
            }
            .navigationTitle("Premium")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarBackButtonHidden(true)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
        .task {
            await subscriptionManager.loadProducts()
            // Auto-select yearly product if available
            if let yearlyProduct = subscriptionManager.getYearlyProduct() {
                selectedProduct = yearlyProduct
            } else if let monthlyProduct = subscriptionManager.getMonthlyProduct() {
                selectedProduct = monthlyProduct
            }
        }
        .alert("Purchase Result", isPresented: $showingPurchaseAlert) {
            Button("OK") { }
        } message: {
            Text(purchaseMessage)
        }
    }
    
    private func purchaseSubscription() {
        guard let product = selectedProduct else { return }
        
        Task {
            subscriptionManager.isLoading = true
            
            do {
                let transaction = try await subscriptionManager.purchase(product)
                
                await MainActor.run {
                    subscriptionManager.isLoading = false
                    
                    if transaction != nil {
                        purchaseMessage = "Subscription activated successfully!"
                        showingPurchaseAlert = true
                        dismiss()
                    } else {
                        purchaseMessage = "Purchase was cancelled."
                        showingPurchaseAlert = true
                    }
                }
            } catch {
                await MainActor.run {
                    subscriptionManager.isLoading = false
                    let errorMessage = error.localizedDescription
                    print("❌ Purchase error: \(errorMessage)")
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
}
