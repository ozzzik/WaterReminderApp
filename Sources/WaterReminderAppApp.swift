import SwiftUI
import UserNotifications

@main
struct WaterReminderAppApp: App {
    @StateObject private var waterReminderManager = WaterReminderManager()
    @StateObject private var notificationManager = NotificationManager()
    @StateObject private var ratingManager = RatingManager()
    @StateObject private var subscriptionManager = SubscriptionManager.shared
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(waterReminderManager)
                .environmentObject(notificationManager)
                .environmentObject(ratingManager)
                .environmentObject(subscriptionManager)
                       .onAppear {
                           // Log system information for debugging
                           print("📱 App launched on iOS \(UIDevice.current.systemVersion)")
                           print("📱 Device: \(UIDevice.current.model)")
                           print("📱 StoreKit available: \(Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") != nil)")
                           
                           notificationManager.requestNotificationPermission()
                           // Increment launch count for rating system
                           ratingManager.incrementLaunchCount()
                           // Connect WaterReminderManager to SubscriptionManager
                           waterReminderManager.subscriptionManager = subscriptionManager
                           // No app-based trial - Apple handles it via subscription trial offer
                       }
        }
    }
}
