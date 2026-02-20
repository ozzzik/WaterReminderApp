import Foundation
import SwiftUI
import UIKit

#if canImport(GoogleMobileAds)
import GoogleMobileAds
#endif

/// Manages rewarded interstitial ads. Reward: "Skip next reminder".
/// When Google Mobile Ads SDK is not linked, acts as a no-op (isAdReady = false, show does nothing).
@MainActor
final class AdManager: NSObject, ObservableObject {
    static let shared = AdManager()

    /// Test ad unit ID — replace with your rewarded interstitial ad unit ID for production.
    private let rewardedInterstitialAdUnitID = "ca-app-pub-3940256099942544/6978759866"

    @Published private(set) var isAdReady = false
    @Published private(set) var isLoading = false

    /// Callback when user earns reward (e.g. skip next reminder).
    var onReward: (() -> Void)?

    #if canImport(GoogleMobileAds)
    private var rewardedInterstitialAd: GADRewardedInterstitialAd?
    #endif

    private override init() {
        super.init()
    }

    /// Call once at app launch (e.g. from WaterReminderAppApp.init or .onAppear).
    func start() {
        #if canImport(GoogleMobileAds)
        GADMobileAds.sharedInstance().start(completionHandler: nil)
        Task { await loadRewardedInterstitial() }
        #endif
    }

    /// Load rewarded interstitial so it's ready when user taps "Watch ad to skip next reminder".
    func loadRewardedInterstitial() async {
        #if canImport(GoogleMobileAds)
        guard !isLoading else { return }
        isLoading = true
        isAdReady = false
        defer { isLoading = false }

        do {
            rewardedInterstitialAd = try await GADRewardedInterstitialAd.load(
                withAdUnitID: rewardedInterstitialAdUnitID,
                request: GADRequest()
            )
            rewardedInterstitialAd?.fullScreenContentDelegate = self
            isAdReady = true
        } catch {
            print("AdMob: Rewarded interstitial failed to load: \(error.localizedDescription)")
        }
        #endif
    }

    /// Present the ad from the given window scene. Calls onReward when user earns the reward.
    func showRewardedInterstitial(from windowScene: UIWindowScene?) {
        #if canImport(GoogleMobileAds)
        guard let ad = rewardedInterstitialAd else {
            print("AdMob: Ad not ready.")
            Task { await loadRewardedInterstitial() }
            return
        }
        guard let rootVC = windowScene?.windows.first?.rootViewController else {
            print("AdMob: No root view controller.")
            return
        }

        ad.present(fromRootViewController: rootVC) { [weak self] in
            self?.onReward?()
            self?.rewardedInterstitialAd = nil
            self?.isAdReady = false
            Task { await self?.loadRewardedInterstitial() }
        }
        #else
        // No-op when SDK not linked
        #endif
    }
}

#if canImport(GoogleMobileAds)
extension AdManager: GADFullScreenContentDelegate {
    nonisolated func adDidRecordImpression(_ ad: GADFullScreenPresentingAd) {
        print("AdMob: adDidRecordImpression")
    }

    nonisolated func adDidRecordClick(_ ad: GADFullScreenPresentingAd) {
        print("AdMob: adDidRecordClick")
    }

    nonisolated func adWillPresentFullScreenContent(_ ad: GADFullScreenPresentingAd) {
        print("AdMob: adWillPresentFullScreenContent")
    }

    nonisolated func adWillDismissFullScreenContent(_ ad: GADFullScreenPresentingAd) {
        print("AdMob: adWillDismissFullScreenContent")
    }

    nonisolated func adDidDismissFullScreenContent(_ ad: GADFullScreenPresentingAd) {
        Task { @MainActor in
            rewardedInterstitialAd = nil
            isAdReady = false
            await loadRewardedInterstitial()
        }
    }

    nonisolated func ad(_ ad: GADFullScreenPresentingAd, didFailToPresentFullScreenContentWithError error: Error) {
        print("AdMob: didFailToPresentFullScreenContentWithError: \(error.localizedDescription)")
        Task { @MainActor in
            rewardedInterstitialAd = nil
            isAdReady = false
            await loadRewardedInterstitial()
        }
    }
}
#endif
