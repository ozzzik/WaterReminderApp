import Foundation
import StoreKit
import UIKit

class RatingManager: ObservableObject {
    @Published var shouldShowRatingRequest = false
    
    private let userDefaults = UserDefaults.standard
    private let appLaunchCountKey = "appLaunchCount"
    private let lastRatingRequestDateKey = "lastRatingRequestDate"
    private let hasRatedKey = "hasRated"
    private let hasDeclinedRatingKey = "hasDeclinedRating"
    
    // Minimum requirements before showing rating request
    private let minLaunchCount = 3
    private let minDaysSinceInstall = 2
    private let daysBetweenRatingRequests = 30
    
    init() {
        checkIfShouldShowRatingRequest()
    }
    
    func incrementLaunchCount() {
        let currentCount = userDefaults.integer(forKey: appLaunchCountKey)
        let newCount = currentCount + 1
        userDefaults.set(newCount, forKey: appLaunchCountKey)
        
        print("📱 App launch count: \(newCount)")
        
        // Check if we should show rating request after incrementing
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            self.checkIfShouldShowRatingRequest()
        }
    }
    
    private func checkIfShouldShowRatingRequest() {
        // Don't show if user has already rated or declined
        if userDefaults.bool(forKey: hasRatedKey) || userDefaults.bool(forKey: hasDeclinedRatingKey) {
            print("📝 Rating request skipped - user has already rated or declined")
            return
        }
        
        // Check launch count
        let launchCount = userDefaults.integer(forKey: appLaunchCountKey)
        if launchCount < minLaunchCount {
            print("📝 Rating request skipped - not enough launches (\(launchCount)/\(minLaunchCount))")
            return
        }
        
        // Check if enough time has passed since last request
        if let lastRequestDate = userDefaults.object(forKey: lastRatingRequestDateKey) as? Date {
            let daysSinceLastRequest = Calendar.current.dateComponents([.day], from: lastRequestDate, to: Date()).day ?? 0
            if daysSinceLastRequest < daysBetweenRatingRequests {
                print("📝 Rating request skipped - too soon since last request (\(daysSinceLastRequest) days)")
                return
            }
        }
        
        // Check if app has been installed for minimum time
        if let installDate = getAppInstallDate() {
            let daysSinceInstall = Calendar.current.dateComponents([.day], from: installDate, to: Date()).day ?? 0
            if daysSinceInstall < minDaysSinceInstall {
                print("📝 Rating request skipped - app installed too recently (\(daysSinceInstall) days)")
                return
            }
        }
        
        // All conditions met - show rating request
        print("⭐ Showing rating request - conditions met")
        DispatchQueue.main.async {
            self.shouldShowRatingRequest = true
        }
    }
    
    private func getAppInstallDate() -> Date? {
        guard let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
            return nil
        }
        
        do {
            let attributes = try FileManager.default.attributesOfItem(atPath: documentsPath.path)
            return attributes[.creationDate] as? Date
        } catch {
            print("❌ Could not get app install date: \(error)")
            return nil
        }
    }
    
    func requestRating() {
        print("⭐ Requesting App Store rating...")
        
        // Record that we've requested rating
        userDefaults.set(Date(), forKey: lastRatingRequestDateKey)
        
        // Hide the rating request UI
        shouldShowRatingRequest = false
        
        // Request the rating using StoreKit
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
            SKStoreReviewController.requestReview(in: windowScene)
        }
    }
    
    func userRated() {
        print("⭐ User rated the app")
        userDefaults.set(true, forKey: hasRatedKey)
        shouldShowRatingRequest = false
    }
    
    func userDeclinedRating() {
        print("⭐ User declined to rate")
        userDefaults.set(true, forKey: hasDeclinedRatingKey)
        shouldShowRatingRequest = false
    }
    
    func resetRatingState() {
        print("🔄 Resetting rating state for testing")
        userDefaults.removeObject(forKey: hasRatedKey)
        userDefaults.removeObject(forKey: hasDeclinedRatingKey)
        userDefaults.removeObject(forKey: lastRatingRequestDateKey)
        userDefaults.set(0, forKey: appLaunchCountKey)
        shouldShowRatingRequest = false
    }
    
    // For testing purposes
    func forceShowRatingRequest() {
        print("🧪 Force showing rating request for testing")
        shouldShowRatingRequest = true
    }
}


