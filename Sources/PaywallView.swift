import SwiftUI

struct PaywallView: View {
    @EnvironmentObject var subscriptionManager: SubscriptionManager
    @Environment(\.dismiss) private var dismiss
    @State private var showingSubscription = false
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            VStack(spacing: 24) {
                Image(systemName: "drop.fill")
                    .font(.system(size: 80))
                    .foregroundColor(.blue)
                
                VStack(spacing: 12) {
                    Text("Your Free Trial Has Ended")
                        .font(.title)
                        .fontWeight(.bold)
                        .multilineTextAlignment(.center)
                    
                    Text("Continue your hydration journey with unlimited access to all features.")
                        .font(.body)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                }
            }
            .padding(.top, 60)
            .padding(.bottom, 40)
            
            // Features List
            VStack(spacing: 16) {
                FeatureRowView(
                    icon: "bell.fill",
                    title: "Unlimited Reminders",
                    description: "Custom intervals from 15 minutes to 4 hours"
                )
                
                FeatureRowView(
                    icon: "chart.line.uptrend.xyaxis",
                    title: "Progress Tracking",
                    description: "Track your daily hydration goals"
                )
                
                FeatureRowView(
                    icon: "plus.circle.fill",
                    title: "Quick Logging",
                    description: "Log water intake with +1/+2 cup actions"
                )
                
                FeatureRowView(
                    icon: "gear",
                    title: "Custom Settings",
                    description: "Personalize your reminder schedule"
                )
            }
            .padding(.horizontal, 20)
            
            Spacer()
            
            // Pricing and CTA
            VStack(spacing: 20) {
                VStack(spacing: 8) {
                    Text("Just $1/month")
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    Text("Less than a coffee per month")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Button(action: {
                    showingSubscription = true
                }) {
                    Text("Continue with Premium")
                        .font(.headline)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 50)
                        .background(Color.blue)
                        .cornerRadius(12)
                }
                .padding(.horizontal, 20)
                
                // Restore Purchases
                Button("Restore Purchases") {
                    Task {
                        await subscriptionManager.restorePurchases()
                    }
                }
                .font(.caption)
                .foregroundColor(.blue)
                
                // Terms
                Text("Cancel anytime. Subscription automatically renews unless auto-renew is turned off at least 24 hours before the end of the current period.")
                    .font(.caption2)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 20)
            }
            .padding(.bottom, 40)
        }
        .sheet(isPresented: $showingSubscription) {
            SubscriptionView()
        }
        .onChange(of: subscriptionManager.isPremiumActive) { isActive in
            if isActive {
                dismiss()
            }
        }
    }
}

struct FeatureRowView: View {
    let icon: String
    let title: String
    let description: String
    
    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(.blue)
                .frame(width: 24)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.headline)
                    .fontWeight(.semibold)
                
                Text(description)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(Color(.systemGray6))
        .cornerRadius(8)
    }
}

#Preview {
    PaywallView()
}
