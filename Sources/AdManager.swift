import Foundation
import SwiftUI
import UIKit

#if canImport(GoogleMobileAds)
import GoogleMobileAds
#endif

/// Manages ads: interstitials after usage, and optional rewarded ad whose reward is "ad-free for the rest of the day".
@MainActor
final class AdManager: NSObject, ObservableObject {
    static let shared = AdManager()

    /// Rewarded Interstitial: "watch ad for ad-free rest of day".
    private let rewardedInterstitialAdUnitID = "ca-app-pub-4048960606079471/8647945776"
    /// Interstitial: pop-up every N water logs.
    private let interstitialAdUnitID = "ca-app-pub-4048960606079471/2517292900"

    private let waterLogsBeforeInterstitial = 3
    private let adFreeRewardDateKey = "adFreeRewardDate"
    private let waterLogCountKey = "waterLogCountSinceLastInterstitial"

    @Published private(set) var isAdReady = false
    @Published private(set) var isLoading = false
    /// True if the user has earned "ad-free for rest of day" today.
    @Published private(set) var isAdFreeForRestOfDay = false

    var onReward: (() -> Void)?

    #if canImport(GoogleMobileAds)
    private var rewardedInterstitialAd: RewardedInterstitialAd?
    private var interstitialAd: InterstitialAd?
    private var isLoadingInterstitial = false
    /// When true, we should show the interstitial as soon as it's loaded (user hit 3 logs but ad wasn't ready).
    private var pendingShowInterstitial = false
    #endif

    private override init() {
        super.init()
        updateAdFreeState()
        NotificationCenter.default.addObserver(
            forName: NSNotification.Name("WaterLogged"),
            object: nil,
            queue: .main
        ) { [weak self] _ in
            Task { @MainActor in
                self?.handleWaterLogged()
            }
        }
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    // MARK: - Ad-free reward (rest of day)

    /// Call when user earns the rewarded ad (watch full ad). Grants ad-free for the rest of the calendar day.
    func grantAdFreeForRestOfDay() {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        UserDefaults.standard.set(today, forKey: adFreeRewardDateKey)
        UserDefaults.standard.synchronize()
        updateAdFreeState()
    }

    private func updateAdFreeState() {
        let calendar = Calendar.current
        guard let date = UserDefaults.standard.object(forKey: adFreeRewardDateKey) as? Date else {
            isAdFreeForRestOfDay = false
            return
        }
        isAdFreeForRestOfDay = calendar.isDateInToday(date)
    }

    /// Call once at app launch.
    func start() {
        print("📺 Ad: start() – GoogleMobileAds available: \(canImportGoogleMobileAds)")
        #if canImport(GoogleMobileAds)
        MobileAds.shared.start(completionHandler: { _ in })
        updateAdFreeState()
        Task {
            try? await Task.sleep(nanoseconds: 500_000_000)
            await loadRewardedInterstitial()
            await loadInterstitial()
        }
        #endif
    }

    private var canImportGoogleMobileAds: Bool {
        #if canImport(GoogleMobileAds)
        return true
        #else
        return false
        #endif
    }

    // MARK: - Rewarded interstitial (opt-in: watch ad for ad-free rest of day)

    func loadRewardedInterstitial() async {
        print("📺 Ad: loadRewardedInterstitial() called")
        #if canImport(GoogleMobileAds)
        guard !isLoading else {
            print("📺 Ad: loadRewardedInterstitial skipped (already loading)")
            return
        }
        isLoading = true
        isAdReady = false
        defer { isLoading = false }
        do {
            rewardedInterstitialAd = try await RewardedInterstitialAd.load(
                with: rewardedInterstitialAdUnitID,
                request: Request()
            )
            rewardedInterstitialAd?.fullScreenContentDelegate = self
            isAdReady = true
            print("📺 Ad: Rewarded interstitial loaded")
        } catch {
            print("AdMob: Rewarded interstitial failed to load: \(error.localizedDescription)")
        }
        #endif
    }

    func showRewardedInterstitial(from windowScene: UIWindowScene?) {
        print("📺 Ad: showRewardedInterstitial(from:) called")
        #if canImport(GoogleMobileAds)
        guard let ad = rewardedInterstitialAd else {
            print("📺 Ad: Rewarded interstitial not loaded – loading…")
            Task { await loadRewardedInterstitial() }
            return
        }
        let rootVC = windowScene?.windows.first(where: { $0.isKeyWindow })?.rootViewController
            ?? windowScene?.windows.first?.rootViewController
            ?? rootViewControllerForAds()
        guard let vc = rootVC else {
            print("📺 Ad: No root view controller for rewarded ad")
            return
        }
        do {
            try ad.canPresent(from: vc)
        } catch {
            print("📺 Ad: Rewarded ad cannot present: \(error.localizedDescription)")
            return
        }
        print("📺 Ad: Presenting rewarded interstitial")
        ad.present(from: vc, userDidEarnRewardHandler: { [weak self] in
            print("📺 Ad: User earned reward – granting ad-free for rest of day")
            self?.onReward?()
            self?.rewardedInterstitialAd = nil
            self?.isAdReady = false
            Task { await self?.loadRewardedInterstitial() }
        })
        #else
        print("📺 Ad: GoogleMobileAds not available – no ad shown")
        #endif
    }

    // MARK: - Interstitial (pop-up after N water logs)

    private func handleWaterLogged() {
        updateAdFreeState()
        if isAdFreeForRestOfDay {
            print("📺 Ad: Skipping interstitial (ad-free for rest of day)")
            return
        }
        let count = UserDefaults.standard.integer(forKey: waterLogCountKey) + 1
        UserDefaults.standard.set(count, forKey: waterLogCountKey)
        UserDefaults.standard.synchronize()
        print("📺 Ad: Water logged, count=\(count) (interstitial after \(waterLogsBeforeInterstitial))")
        if count >= waterLogsBeforeInterstitial {
            UserDefaults.standard.set(0, forKey: waterLogCountKey)
            UserDefaults.standard.synchronize()
            tryShowInterstitial()
        }
    }

    private func tryShowInterstitial() {
        print("📺 Ad: tryShowInterstitial() called")
        #if canImport(GoogleMobileAds)
        let rootVC = rootViewControllerForAds()
        if let ad = interstitialAd, let vc = rootVC {
            print("📺 Ad: Presenting interstitial")
            ad.present(from: vc)
            interstitialAd = nil
            pendingShowInterstitial = false
            Task { await loadInterstitial() }
            return
        }
        print("📺 Ad: Interstitial not ready (ad=\(interstitialAd != nil), rootVC=\(rootVC != nil)) – will show when loaded")
        pendingShowInterstitial = true
        Task { await loadInterstitial() }
        #else
        print("📺 Ad: GoogleMobileAds not available – interstitial skipped")
        #endif
    }

    /// View controller to present full-screen ads. Uses the window's root so we never add a subview to
    /// UIHostingController.view (which would trigger "Adding UIView as subview of UIHostingController.view is not supported").
    private func rootViewControllerForAds() -> UIViewController? {
        let scene = UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .first { $0.activationState == .foregroundActive }
            ?? UIApplication.shared.connectedScenes.compactMap { $0 as? UIWindowScene }.first
        guard let window = scene?.windows.first(where: { $0.isKeyWindow }) ?? scene?.windows.first else { return nil }
        return window.rootViewController
    }

    func loadInterstitial() async {
        #if canImport(GoogleMobileAds)
        guard !isLoadingInterstitial else { return }
        isLoadingInterstitial = true
        defer { isLoadingInterstitial = false }
        do {
            interstitialAd = try await InterstitialAd.load(
                with: interstitialAdUnitID,
                request: Request()
            )
            interstitialAd?.fullScreenContentDelegate = self
            print("📺 Ad: Interstitial loaded")
            if pendingShowInterstitial, let ad = interstitialAd, let vc = rootViewControllerForAds() {
                print("📺 Ad: Presenting interstitial (was pending)")
                pendingShowInterstitial = false
                ad.present(from: vc)
                interstitialAd = nil
                await loadInterstitial()
            }
        } catch {
            print("AdMob: Interstitial failed to load: \(error.localizedDescription)")
        }
        #endif
    }
}

#if canImport(GoogleMobileAds)
extension AdManager: FullScreenContentDelegate {
    nonisolated func adDidDismissFullScreenContent(_ ad: FullScreenPresentingAd) {
        Task { @MainActor in
            rewardedInterstitialAd = nil
            interstitialAd = nil
            isAdReady = false
            await loadRewardedInterstitial()
            await loadInterstitial()
        }
    }

    nonisolated func ad(_ ad: FullScreenPresentingAd, didFailToPresentFullScreenContentWithError error: Error) {
        Task { @MainActor in
            rewardedInterstitialAd = nil
            interstitialAd = nil
            isAdReady = false
            await loadRewardedInterstitial()
            await loadInterstitial()
        }
    }
}
#endif
