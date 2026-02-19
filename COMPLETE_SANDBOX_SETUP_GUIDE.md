# Complete Sandbox Testing Setup Guide

## Overview
This guide will walk you through setting up proper sandbox testing for your Water Reminder App subscription system. We'll transition from StoreKit Configuration to real App Store Connect sandbox testing.

## Phase 1: App Store Connect Setup

### Step 1: Access App Store Connect
1. Go to [App Store Connect](https://appstoreconnect.apple.com/)
2. Sign in with your Apple Developer account
3. Select your Water Reminder App

### Step 2: Configure Subscription Products
1. Navigate to **Features** → **In-App Purchases**
2. Click **+** to add new products
3. Create two auto-renewable subscriptions:

#### Monthly Subscription
- **Product ID**: `com.whio.waterreminder.monthly`
- **Reference Name**: `Premium Monthly`
- **Subscription Duration**: 1 Month
- **Price**: $0.99 (or your preferred price)
- **Display Name**: `Premium Monthly`
- **Description**: `Monthly premium subscription with unlimited access to all features`

#### Yearly Subscription
- **Product ID**: `com.whio.waterreminder.yearly`
- **Reference Name**: `Premium Yearly`
- **Subscription Duration**: 1 Year
- **Price**: $9.99 (or your preferred price)
- **Display Name**: `Premium Yearly`
- **Description**: `Annual premium subscription with unlimited access to all features. Save 17% compared to monthly subscription.`

### Step 3: Create Subscription Group
1. In **In-App Purchases**, go to **Subscription Groups**
2. Click **+** to create new group
3. **Group Name**: `Premium Features`
4. **Group ID**: `21482456` (matches your StoreKit config)
5. Add both monthly and yearly products to this group
6. Set subscription levels (Monthly = 1, Yearly = 2)

### Step 4: Create Sandbox Test Accounts
1. Go to **Users and Access** → **Sandbox Testers**
2. Click **+** to add new testers
3. Create at least 2 test accounts:

#### Test Account 1
- **Email**: `waterreminder.test1@gmail.com`
- **Password**: `Test123!`
- **First Name**: `Test`
- **Last Name**: `User1`
- **Country**: `United States`

#### Test Account 2
- **Email**: `waterreminder.test2@gmail.com`
- **Password**: `Test123!`
- **First Name**: `Test`
- **Last Name**: `User2`
- **Country**: `United States`

## Phase 2: Xcode Configuration

### Step 1: Remove StoreKit Configuration
1. Open your project in Xcode
2. Go to **Product** → **Scheme** → **Edit Scheme...**
3. Select **Run** → **Options** tab
4. Set **StoreKit Configuration** to **None**
5. Click **Close**

### Step 2: Update Subscription Manager
1. Open `Sources/SubscriptionManager.swift`
2. Update test durations to realistic values:

```swift
// Change these lines:
private let monthlySubscriptionMinutes = 30 * 24 * 60  // 30 days
private let yearlySubscriptionMinutes = 365 * 24 * 60  // 365 days
```

### Step 3: Update Debug Controls
1. Open `Sources/SettingsView.swift`
2. Update button labels to reflect real durations:

```swift
// Change button text:
Button("Activate (30 days)") { ... }
Button("Cancel (30 days)") { ... }
```

## Phase 3: Device Setup

### Step 1: Sign Out of Personal Apple ID
1. On your test device, go to **Settings** → **App Store**
2. Tap your Apple ID → **Sign Out**

### Step 2: Sign In with Sandbox Account
1. Open your Water Reminder App
2. Try to make a purchase
3. When prompted, sign in with a sandbox test account
4. Use: `waterreminder.test1@gmail.com` / `Test123!`

### Step 3: Test Purchase Flow
1. Navigate to subscription screen
2. Select monthly subscription
3. Complete purchase with sandbox account
4. Verify subscription activates correctly

## Phase 4: Testing Scenarios

### Test 1: Fresh Install
1. Delete app from device
2. Reinstall and sign in with sandbox account
3. Test trial flow
4. Test subscription purchase

### Test 2: Subscription Management
1. Purchase subscription
2. Go to device **Settings** → **Apple ID** → **Subscriptions**
3. Test cancellation
4. Verify grace period behavior

### Test 3: Subscription Renewal
1. Wait for subscription to expire (or use debug controls)
2. Test renewal flow
3. Verify subscription status updates

### Test 4: Edge Cases
1. Test interrupted purchases
2. Test network failures
3. Test app backgrounding during purchase
4. Test subscription expiration

## Phase 5: Debug Controls for Sandbox

### Updated Debug Controls
Your debug controls will now work with real sandbox data:

- **Start 3min Trial** → Starts real trial (3 minutes)
- **End Trial Now** → Ends trial, shows paywall
- **Reset Trial** → Clears trial data
- **Activate (30 days)** → Simulates 30-day subscription
- **Cancel (30 days)** → Simulates cancellation with grace period
- **Deactivate All** → Clears all subscription data
- **Restore Purchases** → Restores from App Store

## Troubleshooting

### Common Issues

#### Products Not Loading
- Verify product IDs match App Store Connect
- Check sandbox account is signed in
- Ensure products are approved in App Store Connect

#### Purchase Fails
- Check sandbox account has valid payment method
- Verify product is available in sandbox
- Check network connection

#### Subscription Not Activating
- Verify receipt validation is working
- Check subscription group configuration
- Ensure proper StoreKit 2 implementation

### Debug Logs to Monitor
```
🛒 Attempting to load products: [com.whio.waterreminder.monthly, com.whio.waterreminder.yearly]
🛒 Successfully loaded 2 products
💳 Purchase successful: com.whio.waterreminder.monthly
🔄 Subscription status updated: Active
```

## Next Steps

1. **Complete App Store Connect setup**
2. **Test with sandbox accounts**
3. **Verify all subscription flows**
4. **Prepare for TestFlight testing**
5. **Submit for App Store review**

## Production Checklist

- [ ] Remove debug controls
- [ ] Set real subscription durations
- [ ] Test with multiple sandbox accounts
- [ ] Verify receipt validation
- [ ] Test subscription management
- [ ] Prepare app screenshots
- [ ] Submit for review

---

**Note**: Sandbox testing uses real App Store infrastructure but doesn't charge real money. This is the closest you can get to production testing before release.


















