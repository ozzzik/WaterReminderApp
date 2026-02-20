# AdMob setup – step-by-step

This guide walks you through getting your **AdMob App ID** and **Rewarded Interstitial Ad Unit ID**, and where to put them in the Water Reminder app.

---

## What you need before starting

- A **Google account** (Gmail).
- Your app’s **bundle ID**: `com.whio.waterreminder.app` (from Xcode → target WaterReminderApp → General → Bundle Identifier).
- The app already uses **rewarded interstitial** ads with reward **“Skip next reminder”**. You only need to add the SDK and your own IDs.

---

## Part A: Get your AdMob App ID

The **App ID** is one per app. It looks like: `ca-app-pub-XXXXXXXXXXXXXXXX~YYYYYYYYYY` (numbers, with a **tilde ~** in the middle).

### 1. Open AdMob

- Go to **[https://admob.google.com](https://admob.google.com)** and sign in with your Google account.
- If asked, accept the AdMob terms and create your “AdMob account” (this is the publisher account).

### 2. Add your app (if it’s not there yet)

- In the left sidebar, click **Apps**.
- Click **Add app** (or **Add your first app**).
- Choose **iOS**.
- When asked “Is your app listed on a supported app store?”:
  - If the app is **already on the App Store**: choose **Yes**, search for “Water Reminder” (or your app name), select it, and continue.
  - If the app is **not published yet**: choose **No**, then enter:
    - **App name:** e.g. `Water Reminder`
    - **Platform:** iOS
- Click **Add**.

### 3. Register the app with your bundle ID (if you chose “No” above)

- You’ll be asked for the **iOS app store link** or to **register the app manually**.
- If you register manually, use:
  - **App name:** Water Reminder  
  - **Bundle ID:** `com.whio.waterreminder.app`  
  (must match exactly the Bundle Identifier in Xcode.)
- Complete the steps until the app is added.

### 4. Copy the App ID

- In the left menu, go to **Apps** → **All apps** (or **View all apps**).
- Find **Water Reminder** in the list.
- In the **App ID** column you’ll see something like:  
  `ca-app-pub-1234567890123456~1234567890`
- Click the **copy** icon next to that App ID and save it somewhere (you’ll paste it into the project in Part C).

**Summary:** You now have your **AdMob App ID** (format `ca-app-pub-...~...`). This goes into **Info.plist**.

---

## Part B: Get your Rewarded Interstitial Ad Unit ID

The **Ad Unit ID** is per ad placement. It looks like: `ca-app-pub-XXXXXXXXXXXXXXXX/YYYYYYYYYY` (numbers, with a **slash /** in the middle).  
We need one ad unit of type **Rewarded interstitial**.

### 1. Open your app in AdMob

- **Apps** → click **Water Reminder** (your app name).

### 2. Add an ad unit

- Click **Ad units** in the left menu (or the “Ad units” tab).
- Click **Add ad unit**.

### 3. Choose ad format

- Find **Rewarded interstitial** and click it.  
  (If you only see “Rewarded” and “Interstitial” separately, use **Rewarded** for a similar experience; the code uses “rewarded interstitial” – if your AdMob UI only offers “Rewarded”, you can create that and use its ID in the same place; the SDK supports both.)
- Click **Create ad unit**.

### 4. Name and reward (optional but recommended)

- **Ad unit name:** e.g. `Skip next reminder` or `Main rewarded interstitial`.
- **Reward item name:** e.g. `skip_reminder` (used for reporting; can be anything).
- **Reward amount:** e.g. `1` (required; whole number).
- Click **Create ad unit**.

### 5. Copy the Ad unit ID

- On the next screen you’ll see your new ad unit and its **Ad unit ID**, e.g.:  
  `ca-app-pub-1234567890123456/9876543210`
- Click **Copy** (or the copy icon) next to the Ad unit ID and save it.

**Summary:** You now have your **Rewarded interstitial (or Rewarded) Ad unit ID** (format `ca-app-pub-.../...`). This goes into **AdManager.swift**.

---

## Part C: Put the IDs in your project

### 1. App ID → Info.plist

- In Xcode, open **Sources/Info.plist**.
- Find the key **GADApplicationIdentifier**.
- Replace the **value** (the string) with your **AdMob App ID** from Part A.  
  - Current (test): `ca-app-pub-3940256099942544~1458002511`  
  - Yours: e.g. `ca-app-pub-1234567890123456~1234567890`

So the plist entry looks like:

```xml
<key>GADApplicationIdentifier</key>
<string>ca-app-pub-XXXXXXXX~YYYYYYYYYY</string>
```

(Use your real App ID, not the X/Y placeholders.)

### 2. Ad unit ID → AdManager.swift

- In Xcode, open **Sources/AdManager.swift**.
- Find the line with `rewardedInterstitialAdUnitID` (near the top of the file):

```swift
private let rewardedInterstitialAdUnitID = "ca-app-pub-3940256099942544/6978759866"
```

- Replace the **entire string** with your **Rewarded interstitial (or Rewarded) Ad unit ID** from Part B, e.g.:

```swift
private let rewardedInterstitialAdUnitID = "ca-app-pub-1234567890123456/9876543210"
```

Save the file.

**Summary:**

| What              | Where to get it              | Where to put it in the project        |
|-------------------|-----------------------------|----------------------------------------|
| **App ID**        | AdMob → Apps → your app     | **Sources/Info.plist** → `GADApplicationIdentifier` |
| **Ad unit ID**    | AdMob → Apps → your app → Ad units → your rewarded (interstitial) unit | **Sources/AdManager.swift** → `rewardedInterstitialAdUnitID` |

---

## Part D: Add the Google Mobile Ads SDK in Xcode

The app is written to work with the SDK; you just need to add the package and link it.

1. Open **WaterReminderApp.xcodeproj** in Xcode.
2. **File** → **Add Package Dependencies…**
3. In the search field (top right), paste:  
   `https://github.com/googleads/swift-package-manager-google-mobile-ads`
4. When the package appears, select it and click **Add Package**.
5. Ensure the **GoogleMobileAds** product is checked for the **WaterReminderApp** target. Click **Add Package**.
6. Wait for “Resolving package graph” to finish, then build (**Product** → **Build** or Cmd+B).

If the build succeeds, the SDK is linked. The app will then load and show ads using your App ID and Ad unit ID.

---

## Test IDs vs your own IDs

- **During development** you can keep using the **test** IDs already in the project:
  - App ID (test): `ca-app-pub-3940256099942544~1458002511`
  - Ad unit ID (test): `ca-app-pub-3940256099942544/6978759866`  
  Test ads will show and you won’t risk policy issues.
- **Before release** replace both with your **real** AdMob App ID and Ad unit ID from Parts A and B, and put them in **Info.plist** and **AdManager.swift** as in Part C.

---

## Quick reference: ID formats

- **App ID:**  
  `ca-app-pub-` + **publisher number** + `~` + **app number**  
  Example: `ca-app-pub-1234567890123456~1234567890`
- **Ad unit ID:**  
  `ca-app-pub-` + **publisher number** + `/` + **ad unit number**  
  Example: `ca-app-pub-1234567890123456/9876543210`

You can see both in AdMob under **Apps** → your app → **App settings** (App ID) and **Ad units** (Ad unit IDs).

---

## App verification: app-ads.txt

AdMob may ask you to verify the app with an **app-ads.txt** file on your developer website. If you see “We couldn’t verify [your app]” and it mentions app-ads.txt:

1. **Use the exact line AdMob shows** (it includes your publisher ID). For your account it is:
   ```
   google.com, pub-4048960606079471, DIRECT, f08c47fec0942fa0
   ```

2. **Put it at the root of your developer website**  
   The URL must be: `https://<your-developer-domain>/app-ads.txt`  
   For this project, the developer site is **https://ozzzik.github.io/WaterReminderApp/** so the file must be available at:
   **https://ozzzik.github.io/WaterReminderApp/app-ads.txt**

3. **In this repo** the file is **docs/app-ads.txt**.  
   - If GitHub Pages is set to “Deploy from branch” with source **/docs**, then `docs/app-ads.txt` is already at the site root and the URL above will work after you push and Pages rebuilds.  
   - If your Pages site is built from the repo root instead, move `app-ads.txt` to the repo root so that `https://ozzzik.github.io/WaterReminderApp/app-ads.txt` serves that file.

4. In AdMob, open your app → **Check for updates** (or re-run verification). Verification can take a short while.

The domain in App Store Connect for your app (Support URL / Marketing URL) must match the domain where app-ads.txt is hosted (e.g. `ozzzik.github.io`).

---

## Privacy and App Store

- **Privacy policy:** Already updated in **docs/privacy-policy.html** for ad serving and AdMob (see “Advertising” and “Third-Party Services”).
- **App Store Connect:** In **App Privacy**, declare that you use **Advertising** (and any data types AdMob/Google describe in their policy), so your listing matches your privacy policy and the SDK behavior.

If you want, the next step can be a short checklist for App Store Connect “App Privacy” for this app and AdMob.
