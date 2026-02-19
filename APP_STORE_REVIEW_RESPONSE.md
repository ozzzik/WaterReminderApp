# Response to App Store Review

## Premium Yearly Subscription Location in Binary

Thank you for your inquiry. The **Premium Yearly subscription** can be located in the binary at the following locations:

### Product ID
**`com.whio.waterreminder.yearly.v4`**

### Key Locations in Binary:

1. **Product Definition**
   - **File**: `SubscriptionManager.swift`
   - **Lines**: 24-27
   - Hardcoded product ID: `"com.whio.waterreminder.yearly.v4"`

2. **User Interface Display**
   - **File**: `SubscriptionView.swift`
   - **Lines**: 69-78
   - Displays the Premium Yearly subscription as a selectable option with "BEST VALUE" badge
   - Auto-selected by default (lines 161-163)

3. **Purchase Functionality**
   - **File**: `SubscriptionView.swift`
   - **Lines**: 179-218
   - Users can purchase the Premium Yearly subscription by selecting it and tapping "Start Free Trial"

4. **StoreKit Integration**
   - **File**: `SubscriptionManager.swift`
   - **Lines**: 76-93 (Product loading)
   - **Lines**: 98-174 (Purchase handling)
   - **Lines**: 206-264 (Status checking)

5. **StoreKit Configuration**
   - **File**: `Configuration.storekit`
   - **Lines**: 105-133
   - Display Name: "Premium Yearly"
   - Reference Name: "Premium Yearly"
   - Period: Yearly (P1Y)

### How to Access in App:

1. Launch the app
2. Tap "Continue with Premium" (or navigate to Settings → Manage Subscription)
3. The subscription screen (`SubscriptionView`) will display both options
4. **Premium Yearly** is the top option, auto-selected, marked as "BEST VALUE"
5. Tap "Start Free Trial" to purchase the Premium Yearly subscription

The Premium Yearly subscription is fully integrated into the app's purchase flow and is the default selected option when users access the subscription screen.

---

**Additional Notes:**
- The subscription is part of subscription group "21482456" (Premium Features)
- Both monthly and yearly subscriptions are in the same group, allowing users to switch between them
- The yearly subscription includes a 7-day free trial period
- The product is loaded dynamically from the App Store using StoreKit2


