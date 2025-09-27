import SwiftUI

struct TrialBannerView: View {
    @StateObject private var subscriptionManager = SubscriptionManager.shared
    
    var body: some View {
        if subscriptionManager.isTrialActive {
            VStack(spacing: 0) {
                HStack {
                    Image(systemName: "clock.fill")
                        .foregroundColor(.orange)
                    
                    Text("Free Trial: \(subscriptionManager.trialDaysRemaining) days left")
                        .font(.caption)
                        .fontWeight(.medium)
                        .foregroundColor(.orange)
                    
                    Spacer()
                    
                    Button("Upgrade") {
                        // This will be handled by the parent view
                    }
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundColor(.blue)
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(Color.orange.opacity(0.1))
                .cornerRadius(8)
                
                Divider()
                    .padding(.top, 8)
            }
            .onAppear {
                subscriptionManager.checkTrialStatus()
            }
        }
    }
}

#Preview {
    TrialBannerView()
        .padding()
}
