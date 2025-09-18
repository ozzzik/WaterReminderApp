import SwiftUI

struct RatingRequestView: View {
    @ObservedObject var ratingManager: RatingManager
    @State private var isAnimating = false
    
    var body: some View {
        VStack(spacing: 20) {
            // Header with star icon
            VStack(spacing: 10) {
                Image(systemName: "star.fill")
                    .font(.system(size: 50))
                    .foregroundColor(.yellow)
                    .scaleEffect(isAnimating ? 1.1 : 1.0)
                    .animation(.easeInOut(duration: 1.0).repeatForever(autoreverses: true), value: isAnimating)
                
                Text("Enjoying Water Reminder?")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
                
                Text("Your feedback helps us improve and helps other users discover the app!")
                    .font(.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
            }
            
            // Rating buttons
            VStack(spacing: 12) {
                Button(action: {
                    ratingManager.requestRating()
                }) {
                    HStack {
                        Image(systemName: "star.fill")
                            .foregroundColor(.white)
                        Text("Rate Water Reminder")
                            .fontWeight(.medium)
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(
                        LinearGradient(
                            gradient: Gradient(colors: [.blue, .cyan]),
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .cornerRadius(12)
                }
                
                Button(action: {
                    ratingManager.userDeclinedRating()
                }) {
                    Text("Maybe Later")
                        .fontWeight(.medium)
                        .foregroundColor(.secondary)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(12)
                }
            }
            .padding(.horizontal)
            
            // Small text at bottom
            Text("This will open the App Store")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding(24)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 5)
        )
        .padding(.horizontal, 20)
        .onAppear {
            isAnimating = true
        }
    }
}

#Preview {
    ZStack {
        Color(.systemGray5)
            .ignoresSafeArea()
        
        RatingRequestView(ratingManager: RatingManager())
    }
}
