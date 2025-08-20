import SwiftUI
import UserNotifications

@main
struct WaterReminderAppApp: App {
    @StateObject private var waterReminderManager = WaterReminderManager()
    @StateObject private var notificationManager = NotificationManager()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(waterReminderManager)
                .environmentObject(notificationManager)
                .onAppear {
                    notificationManager.requestNotificationPermission()
                }
        }
    }
}
