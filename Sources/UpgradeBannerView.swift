import SwiftUI

/// Simple upgrade banner (no app-based trial)
/// Apple handles trial via subscription introductory offer
struct UpgradeBannerView: View {
    @EnvironmentObject var subscriptionManager: SubscriptionManager
    @State private var showingPaywall = false
    
    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: 12) {
                Image(systemName: "star.fill")
                    .foregroundColor(.yellow)
                    .font(.title3)
                
                VStack(alignment: .leading, spacing: 3) {
                    Text("Try Premium Free for 7 Days")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                    
                    Text("Then just $0.99/month")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                Button("Start Free Trial") {
                    showingPaywall = true
                }
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundColor(.white)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(Color.blue)
                .cornerRadius(8)
            }
            .padding()
            .background(Color.blue.opacity(0.1))
            
            Divider()
        }
        .sheet(isPresented: $showingPaywall) {
            PaywallView()
                .environmentObject(subscriptionManager)
        }
    }
}

#Preview {
    UpgradeBannerView()
        .environmentObject(SubscriptionManager.shared)
}




