import SwiftUI

struct PaywallView: View {
    @EnvironmentObject var subscriptionManager: SubscriptionManager
    @Environment(\.dismiss) private var dismiss
    @State private var showingSubscription = false
    
    // iPad-specific layout properties
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    @Environment(\.verticalSizeClass) private var verticalSizeClass
    
    private var isIPad: Bool {
        let isIPadSizeClass = horizontalSizeClass == .regular && verticalSizeClass == .regular
        let isIPadDevice = UIDevice.current.userInterfaceIdiom == .pad
        let isIPadDetected = isIPadSizeClass || isIPadDevice
        print("🔍 PaywallView iPad Detection - horizontalSizeClass: \(horizontalSizeClass == .regular ? "regular" : "compact"), verticalSizeClass: \(verticalSizeClass == .regular ? "regular" : "compact"), deviceIdiom: \(UIDevice.current.userInterfaceIdiom.rawValue), isIPadSizeClass: \(isIPadSizeClass), isIPadDevice: \(isIPadDevice), final isIPad: \(isIPadDetected)")
        return isIPadDetected
    }
    
    var body: some View {
        GeometryReader { geometry in
            VStack(spacing: 0) {
                if isIPad {
                    // iPad: Fixed layout with purchase button always visible
                    VStack(spacing: 0) {
                        // Scrollable content area
                        ScrollView {
                            VStack(spacing: 30) {
                                // Header
                                VStack(spacing: 20) {
                                    Image(systemName: "drop.fill")
                                        .font(.system(size: 80))
                                        .foregroundColor(.blue)
                                    
                                    VStack(spacing: 10) {
                                        Text("Try Premium Free for 7 Days")
                                            .font(.title)
                                            .fontWeight(.bold)
                                            .multilineTextAlignment(.center)
                                        
                                        Text("Start your free trial. Cancel anytime. No charge until trial ends.")
                                            .font(.body)
                                            .foregroundColor(.secondary)
                                            .multilineTextAlignment(.center)
                                            .padding(.horizontal)
                                    }
                                }
                                .padding(.top, 20)
                                .padding(.bottom, 20)
                                
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
                                .padding(.horizontal, max(40, geometry.size.width * 0.1))
                            }
                        }
                        
                        // Fixed bottom section with purchase button
                        VStack(spacing: 16) {
                            Divider()
                            
                            // Pricing and CTA - Always visible
                            VStack(spacing: 16) {
                                VStack(spacing: 8) {
                                    Text("Just $1/month")
                                        .font(.title2)
                                        .fontWeight(.bold)
                                    
                                    Text("Less than a coffee per month")
                                        .font(.subheadline)
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
                                .padding(.horizontal, max(40, geometry.size.width * 0.1))
                                
                                // Restore Purchases
                                Button("Restore Purchases") {
                                    Task {
                                        await subscriptionManager.restorePurchases()
                                    }
                                }
                                .font(.subheadline)
                                .foregroundColor(.blue)
                                
                                // Terms and Privacy Policy Links
                                VStack(spacing: 8) {
                                    Text("Cancel anytime. Subscription automatically renews unless auto-renew is turned off at least 24 hours before the end of the current period.")
                                        .font(.caption2)
                                        .foregroundColor(.secondary)
                                        .multilineTextAlignment(.center)
                                    
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
                                }
                            }
                            .padding(.horizontal, max(40, geometry.size.width * 0.1))
                            .padding(.vertical, 20)
                            .background(Color(.systemBackground))
                        }
                    }
                } else {
                    // iPhone: Single column layout
                    // Header
                    VStack(spacing: 24) {
                        Image(systemName: "drop.fill")
                            .font(.system(size: 80))
                            .foregroundColor(.blue)
                        
                        VStack(spacing: 12) {
                            Text("Try Premium Free for 7 Days")
                                .font(.title)
                                .fontWeight(.bold)
                                .multilineTextAlignment(.center)
                            
                            Text("Start your free trial. Cancel anytime. No charge until trial ends.")
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
                        
                        // Terms and Privacy Policy Links
                        VStack(spacing: 8) {
                            Text("Cancel anytime. Subscription automatically renews unless auto-renew is turned off at least 24 hours before the end of the current period.")
                                .font(.caption2)
                                .foregroundColor(.secondary)
                                .multilineTextAlignment(.center)
                            
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
                        }
                        .padding(.horizontal, 20)
                    }
                    .padding(.bottom, 40)
                }
            }
        }
        .fullScreenCover(isPresented: $showingSubscription) {
            NavigationStack {
                SubscriptionView()
                    .environmentObject(subscriptionManager)
                    .navigationTitle("Premium")
                    .navigationBarTitleDisplayMode(.inline)
                    .navigationBarBackButtonHidden(true)
                    .toolbar {
                        ToolbarItem(placement: .navigationBarLeading) {
                            Button("Cancel") {
                                showingSubscription = false
                            }
                        }
                    }
            }
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
    
    // iPad-specific layout properties
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    @Environment(\.verticalSizeClass) private var verticalSizeClass
    
    private var isIPad: Bool {
        horizontalSizeClass == .regular && verticalSizeClass == .regular
    }
    
    var body: some View {
        HStack(spacing: isIPad ? 20 : 16) {
            Image(systemName: icon)
                .font(isIPad ? .title : .title2)
                .foregroundColor(.blue)
                .frame(width: isIPad ? 32 : 24)
            
            VStack(alignment: .leading, spacing: isIPad ? 4 : 2) {
                Text(title)
                    .font(isIPad ? .title3 : .headline)
                    .fontWeight(.semibold)
                
                Text(description)
                    .font(isIPad ? .subheadline : .caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
        }
        .padding(.horizontal, isIPad ? 20 : 16)
        .padding(.vertical, isIPad ? 16 : 12)
        .background(Color(.systemGray6))
        .cornerRadius(isIPad ? 12 : 8)
    }
}

#Preview {
    PaywallView()
}
