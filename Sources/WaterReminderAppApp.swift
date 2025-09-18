import SwiftUI
import UserNotifications

@main
struct WaterReminderAppApp: App {
    @StateObject private var waterReminderManager = WaterReminderManager()
    @StateObject private var notificationManager = NotificationManager()
    @StateObject private var ratingManager = RatingManager()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(waterReminderManager)
                .environmentObject(notificationManager)
                .environmentObject(ratingManager)
                .onAppear {
                    notificationManager.requestNotificationPermission()
                    // Increment launch count for rating system
                    ratingManager.incrementLaunchCount()
                }
        }
    }
}
