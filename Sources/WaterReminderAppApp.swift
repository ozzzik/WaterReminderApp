import SwiftUI
import UserNotifications

@main
struct WaterReminderAppApp: App {
    @StateObject private var waterReminderManager = WaterReminderManager()
    @StateObject private var notificationManager = NotificationManager()
    @StateObject private var ratingManager = RatingManager()
    @StateObject private var subscriptionManager = SubscriptionManager.shared
    @StateObject private var adManager = AdManager.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(waterReminderManager)
                .environmentObject(notificationManager)
                .environmentObject(ratingManager)
                .environmentObject(subscriptionManager)
                .environmentObject(adManager)
                .onAppear {
                    print("📱 App launched on iOS \(UIDevice.current.systemVersion)")
                    print("📱 Device: \(UIDevice.current.model)")

                    notificationManager.requestNotificationPermission()
                    ratingManager.incrementLaunchCount()
                    waterReminderManager.subscriptionManager = subscriptionManager

                    // Ads: reward = ad-free for the rest of the day
                    adManager.onReward = { [adManager] in
                        DispatchQueue.main.async { adManager.grantAdFreeForRestOfDay() }
                    }
                    adManager.start()
                }
        }
    }
}
