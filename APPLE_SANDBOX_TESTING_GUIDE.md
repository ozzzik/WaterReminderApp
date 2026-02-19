# Complete Apple Sandbox Testing Guide

## Overview
This guide will walk you through setting up and testing your Water Reminder App subscription system using Apple's sandbox environment. Sandbox testing uses real App Store infrastructure but doesn't charge real money.

## Prerequisites
- Apple Developer Account ($99/year)
- App registered in App Store Connect
- Physical iOS device (iPhone/iPad)
- Xcode installed
- Your app built and ready

## Phase 1: App Store Connect Setup

### Step 1: Access App Store Connect
1. Go to [App Store Connect](https://appstoreconnect.apple.com/)
2. Sign in with your Apple Developer account
3. Click **My Apps**
4. Select your **Water Reminder App**

### Step 2: Create Subscription Products
1. In your app, go to **Features** tab
2. Scroll down to **In-App Purchases**
3. Click **+** button to add new products
4. Select **Auto-Renewable Subscriptions**

#### Create Monthly Subscription
1. **Product ID**: `com.whio.waterreminder.monthly`
2. **Reference Name**: `Premium Monthly`
3. **Subscription Duration**: 1 Month
4. **Price**: $0.99 (or your preferred price)
5. **Display Name**: `Premium Monthly`
6. **Description**: `Monthly premium subscription with unlimited access to all features`
7. Click **Save**

#### Create Yearly Subscription
1. **Product ID**: `com.whio.waterreminder.yearly`
2. **Reference Name**: `Premium Yearly`
3. **Subscription Duration**: 1 Year
4. **Price**: $9.99 (or your preferred price)
5. **Display Name**: `Premium Yearly`
6. **Description**: `Annual premium subscription with unlimited access to all features. Save 17% compared to monthly subscription.`
7. Click **Save**

### Step 3: Create Subscription Group
1. In **In-App Purchases**, go to **Subscription Groups**
2. Click **+** to create new group
3. **Group Name**: `Premium Features`
4. **Group ID**: `21482456` (matches your StoreKit config)
5. Click **Save**
6. Add both monthly and yearly products to this group
7. Set subscription levels:
   - Monthly = Level 1
   - Yearly = Level 2

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
- **Date of Birth**: `01/01/1990`

#### Test Account 2
- **Email**: `waterreminder.test2@gmail.com`
- **Password**: `Test123!`
- **First Name**: `Test`
- **Last Name**: `User2`
- **Country**: `United States`
- **Date of Birth**: `01/01/1990`

4. Click **Save** for each account

### Step 5: Submit Products for Review (Optional)
- For sandbox testing, products don't need to be approved
- For production, you'll need to submit for review
- Click **Submit for Review** on each product when ready

## Phase 2: Xcode Configuration

### Step 1: Remove StoreKit Configuration
1. Open your project in Xcode
2. Go to **Product** → **Scheme** → **Edit Scheme...**
3. Select **Run** → **Options** tab
4. Set **StoreKit Configuration** to **None**
5. Click **Close**

### Step 2: Update Bundle Identifier
1. In Xcode, select your project
2. Go to **Signing & Capabilities**
3. Ensure **Bundle Identifier** matches App Store Connect: `com.whio.waterreminder.app`
4. Ensure **Team** is set to your developer team

### Step 3: Build and Deploy
1. Connect your iOS device
2. Select your device as the build target
3. Build and run the app
4. Ensure the app installs successfully

## Phase 3: Device Setup

### Step 1: Sign Out of Personal Apple ID
1. On your test device, go to **Settings** → **App Store**
2. Tap your Apple ID → **Sign Out**
3. Confirm sign out

### Step 2: Clear App Store Cache
1. Go to **Settings** → **General** → **iPhone Storage**
2. Find **App Store** app
3. Tap **Offload App** (this clears cache)
4. Reinstall App Store if needed

### Step 3: Prepare for Sandbox Sign-In
1. Open your Water Reminder App
2. Navigate to subscription screen
3. Attempt to make a purchase
4. When prompted, sign in with sandbox account:
   - Email: `waterreminder.test1@gmail.com`
   - Password: `Test123!`

## Phase 4: Testing Scenarios (Detailed)

### Test 1: Fresh Install & First Launch

#### Purpose
Verify the app behaves correctly for new users with no previous data.

#### Steps
1. **Delete app from device**
   - Long press app icon → Remove App → Delete App
   - Confirm deletion

2. **Reinstall app**
   - Build and deploy from Xcode
   - Or install from TestFlight (if available)

3. **Launch app for first time**
   - App should start normally
   - Check if trial banner appears
   - Verify trial countdown starts (3 minutes)

4. **Sign in with sandbox account**
   - Navigate to subscription screen
   - Attempt to make a purchase
   - When prompted, sign in with: `waterreminder.test1@gmail.com` / `Test123!`
   - Verify sign-in succeeds

5. **Test trial flow**
   - Verify trial banner shows "Free Trial: 3:00 remaining"
   - Check that premium features are accessible
   - Verify trial countdown decreases every second
   - Wait for trial to expire (or use debug controls)
   - Confirm paywall appears when trial ends

6. **Test subscription purchase**
   - Navigate to subscription screen
   - Select monthly subscription ($0.99/month)
   - Complete purchase with sandbox account
   - Verify purchase succeeds
   - Check subscription activates immediately

#### Expected Results
- ✅ App launches without errors
- ✅ Trial starts automatically (3 minutes)
- ✅ Premium features accessible during trial
- ✅ Paywall appears when trial expires
- ✅ Subscription purchase succeeds
- ✅ Subscription activates immediately

#### Debug Logs to Monitor
```
🆓 Trial started - 3 minutes remaining
💳 Purchase successful: com.whio.waterreminder.monthly
🔄 Subscription status updated: Active
```

---

### Test 2: Subscription Purchase Flow

#### Purpose
Verify the complete subscription purchase process works correctly.

#### Steps
1. **Navigate to subscription screen**
   - Open app
   - Go to Settings → Subscription
   - Or tap "Upgrade to Premium" banner

2. **Select monthly subscription**
   - Tap "Monthly" option
   - Verify price displays correctly ($0.99/month)
   - Check subscription description

3. **Complete purchase with sandbox account**
   - Tap "Subscribe" button
   - Apple purchase dialog appears
   - Sign in with sandbox account if prompted
   - Confirm purchase
   - Wait for purchase to complete

4. **Verify subscription activates**
   - Check subscription status in app
   - Verify premium features are accessible
   - Check trial banner disappears
   - Verify subscription expiration date

5. **Check subscription status in Settings**
   - Go to device Settings → Apple ID → Subscriptions
   - Find "Water Reminder App" subscription
   - Verify subscription details are correct
   - Check renewal date

#### Expected Results
- ✅ Purchase dialog appears correctly
- ✅ Purchase completes successfully
- ✅ Subscription activates immediately
- ✅ Premium features accessible
- ✅ Subscription appears in device Settings
- ✅ Renewal date is correct

#### Debug Logs to Monitor
```
🛒 Attempting to load products: [com.whio.waterreminder.monthly, com.whio.waterreminder.yearly]
🛒 Successfully loaded 2 products
💳 Purchase successful: com.whio.waterreminder.monthly
🔄 Subscription status updated: Active
```

---

### Test 3: Subscription Management

#### Purpose
Verify users can manage their subscriptions through device Settings.

#### Steps
1. **Go to device Settings → Apple ID → Subscriptions**
   - Open Settings app
   - Tap your Apple ID at the top
   - Tap "Subscriptions"
   - Find "Water Reminder App" subscription

2. **Test cancellation**
   - Tap on your app subscription
   - Tap "Cancel Subscription"
   - Confirm cancellation
   - Verify cancellation confirmation appears

3. **Verify grace period behavior**
   - Return to your app
   - Check subscription status
   - Verify subscription still shows as active
   - Check expiration date (should be end of current period)
   - Verify "Subscription Cancelled" status appears

4. **Test resubscription**
   - Wait for subscription to expire (or use debug controls)
   - Attempt to purchase subscription again
   - Verify purchase succeeds
   - Check subscription reactivates

5. **Test subscription changes**
   - Go back to device Settings → Subscriptions
   - Try to change from monthly to yearly
   - Verify change succeeds
   - Check new expiration date

#### Expected Results
- ✅ Subscription appears in device Settings
- ✅ Cancellation works correctly
- ✅ Grace period maintained until expiration
- ✅ App shows "Subscription Cancelled" status
- ✅ Resubscription works
- ✅ Subscription changes work

#### Debug Logs to Monitor
```
🧪 DEBUG: Subscription cancelled - will expire at 2024-11-02 15:30:00 +0000
🔄 Subscription status updated: Cancelled
💳 Purchase successful: com.whio.waterreminder.monthly
🔄 Subscription status updated: Active
```

---

### Test 4: Subscription Renewal

#### Purpose
Verify subscription renewal works correctly when subscription expires.

#### Steps
1. **Wait for subscription to expire (or use debug controls)**
   - Use debug controls to simulate expiration
   - Or wait for actual expiration (30 days for sandbox)
   - Check subscription status changes

2. **Test renewal flow**
   - Attempt to access premium features
   - Verify paywall appears
   - Navigate to subscription screen
   - Purchase subscription again
   - Verify renewal succeeds

3. **Verify subscription status updates**
   - Check subscription status in app
   - Verify premium features accessible again
   - Check new expiration date
   - Verify subscription appears in device Settings

4. **Test failed renewal scenarios**
   - Simulate payment failure (if possible)
   - Check app behavior
   - Verify grace period handling
   - Test retry mechanism

#### Expected Results
- ✅ Subscription expires correctly
- ✅ Paywall appears when expired
- ✅ Renewal purchase succeeds
- ✅ Subscription reactivates
- ✅ New expiration date set
- ✅ Grace period handled correctly

#### Debug Logs to Monitor
```
🔄 Subscription expired - showing paywall
💳 Purchase successful: com.whio.waterreminder.monthly
🔄 Subscription status updated: Active
```

---

### Test 5: Edge Cases & Error Scenarios

#### Purpose
Verify the app handles edge cases and error scenarios gracefully.

#### Steps
1. **Test interrupted purchases**
   - Start a subscription purchase
   - Interrupt by switching apps
   - Return to app
   - Verify purchase state
   - Complete or cancel purchase

2. **Test network failures**
   - Disable network connection
   - Attempt to make purchase
   - Verify error handling
   - Re-enable network
   - Retry purchase

3. **Test app backgrounding during purchase**
   - Start subscription purchase
   - Background the app
   - Return to app
   - Verify purchase completion
   - Check subscription status

4. **Test subscription expiration**
   - Use debug controls to expire subscription
   - Verify premium features become inaccessible
   - Check paywall appears
   - Test subscription purchase flow

5. **Test restore purchases**
   - Delete and reinstall app
   - Sign in with same sandbox account
   - Tap "Restore Purchases"
   - Verify subscription restores
   - Check premium features accessible

6. **Test multiple subscription attempts**
   - Attempt to purchase while already subscribed
   - Verify error handling
   - Check subscription status unchanged

7. **Test subscription group changes**
   - Purchase monthly subscription
   - Attempt to purchase yearly subscription
   - Verify upgrade/downgrade behavior
   - Check subscription levels

#### Expected Results
- ✅ Interrupted purchases handled gracefully
- ✅ Network failures show appropriate errors
- ✅ App backgrounding doesn't break purchases
- ✅ Subscription expiration handled correctly
- ✅ Restore purchases works
- ✅ Multiple subscription attempts handled
- ✅ Subscription group changes work

#### Debug Logs to Monitor
```
❌ Network error during purchase
🔄 Purchase interrupted - resuming
🔄 Restoring purchases...
💳 Purchase restored: com.whio.waterreminder.monthly
```

---

### Test 6: Trial & Subscription Interactions

#### Purpose
Verify trial and subscription interactions work correctly.

#### Steps
1. **Test trial during active subscription**
   - Start with active subscription
   - Use debug controls to start trial
   - Verify trial doesn't interfere with subscription
   - Check subscription remains active

2. **Test subscription during trial**
   - Start trial
   - Purchase subscription during trial
   - Verify trial ends immediately
   - Check subscription activates

3. **Test trial after subscription cancellation**
   - Cancel subscription
   - Wait for expiration
   - Use debug controls to start trial
   - Verify trial works after subscription

4. **Test multiple trial attempts**
   - Use trial
   - Let trial expire
   - Attempt to start trial again
   - Verify trial blocked (hasUsedTrial = true)

#### Expected Results
- ✅ Trial doesn't interfere with active subscription
- ✅ Subscription ends trial immediately
- ✅ Trial works after subscription cancellation
- ✅ Multiple trials blocked correctly

#### Debug Logs to Monitor
```
🆓 Trial started - 3 minutes remaining
💳 Purchase successful: com.whio.waterreminder.monthly
🛑 Premium activated - stopping trial
🔄 Subscription status updated: Active
```

---

### Test 7: Receipt Validation

#### Purpose
Verify receipt validation works correctly with sandbox.

#### Steps
1. **Test receipt validation on launch**
   - Launch app
   - Check receipt validation occurs
   - Verify subscription status updates
   - Check debug logs for validation

2. **Test receipt validation after purchase**
   - Make subscription purchase
   - Check receipt validation occurs
   - Verify subscription activates
   - Check validation logs

3. **Test receipt validation after restore**
   - Restore purchases
   - Check receipt validation occurs
   - Verify subscription restores
   - Check validation logs

4. **Test receipt validation errors**
   - Simulate validation errors (if possible)
   - Check error handling
   - Verify fallback behavior
   - Check error logs

#### Expected Results
- ✅ Receipt validation occurs on launch
- ✅ Receipt validation occurs after purchase
- ✅ Receipt validation occurs after restore
- ✅ Validation errors handled gracefully

#### Debug Logs to Monitor
```
🔄 Validating receipts...
✅ Receipt validation successful
❌ Receipt validation failed: [error]
```

---

### Test 8: UI State Management

#### Purpose
Verify UI updates correctly based on subscription status.

#### Steps
1. **Test trial banner updates**
   - Start trial
   - Verify banner shows countdown
   - Check banner updates every second
   - Verify banner disappears when trial ends

2. **Test subscription status display**
   - Purchase subscription
   - Check subscription status in Settings
   - Verify status updates correctly
   - Check expiration date display

3. **Test paywall appearance**
   - Let trial expire
   - Verify paywall appears
   - Check paywall content
   - Verify subscription options

4. **Test premium feature access**
   - During trial: verify features accessible
   - After trial: verify features blocked
   - With subscription: verify features accessible
   - After cancellation: verify features blocked

#### Expected Results
- ✅ Trial banner updates correctly
- ✅ Subscription status displays correctly
- ✅ Paywall appears when needed
- ✅ Premium features access controlled correctly

#### Debug Logs to Monitor
```
🆓 Trial time remaining: 2:45
💳 Subscription active until: 2024-11-02 15:30:00 +0000
🔄 Paywall shown - trial expired
```

---

### Test 9: Performance & Stability

#### Purpose
Verify app performance and stability during subscription flows.

#### Steps
1. **Test rapid subscription changes**
   - Purchase subscription
   - Cancel immediately
   - Purchase again
   - Repeat multiple times
   - Check app stability

2. **Test memory usage**
   - Monitor memory usage during subscription flows
   - Check for memory leaks
   - Verify app doesn't crash
   - Check performance

3. **Test background/foreground transitions**
   - Start subscription purchase
   - Background app
   - Return to app
   - Repeat multiple times
   - Check app stability

4. **Test concurrent operations**
   - Start multiple subscription operations
   - Check error handling
   - Verify app doesn't crash
   - Check operation completion

#### Expected Results
- ✅ App remains stable during rapid changes
- ✅ Memory usage stays reasonable
- ✅ Background/foreground transitions work
- ✅ Concurrent operations handled correctly

#### Debug Logs to Monitor
```
🔄 Multiple operations detected - queuing
⚠️ Memory usage: 45MB
✅ Operation completed successfully
```

---

### Test 10: Sandbox Account Management

#### Purpose
Verify sandbox account management works correctly.

#### Steps
1. **Test multiple sandbox accounts**
   - Create multiple sandbox accounts
   - Test purchases with different accounts
   - Verify account isolation
   - Check subscription status per account

2. **Test account switching**
   - Sign in with one sandbox account
   - Make purchase
   - Sign out
   - Sign in with different account
   - Verify subscription status

3. **Test account deletion**
   - Delete sandbox account
   - Attempt to make purchase
   - Verify error handling
   - Check app behavior

4. **Test account restoration**
   - Restore deleted sandbox account
   - Attempt to make purchase
   - Verify purchase succeeds
   - Check subscription status

#### Expected Results
- ✅ Multiple accounts work correctly
- ✅ Account switching works
- ✅ Account deletion handled gracefully
- ✅ Account restoration works

#### Debug Logs to Monitor
```
🧪 Sandbox account: waterreminder.test1@gmail.com
💳 Purchase successful with account: waterreminder.test1@gmail.com
❌ Account not found: waterreminder.test3@gmail.com
```

---

## Testing Checklist

### Basic Functionality
- [ ] App launches without errors
- [ ] Trial starts automatically
- [ ] Premium features accessible during trial
- [ ] Paywall appears when trial expires
- [ ] Subscription purchase succeeds
- [ ] Subscription activates immediately

### Subscription Management
- [ ] Subscription appears in device Settings
- [ ] Cancellation works correctly
- [ ] Grace period maintained until expiration
- [ ] App shows "Subscription Cancelled" status
- [ ] Resubscription works
- [ ] Subscription changes work

### Edge Cases
- [ ] Interrupted purchases handled gracefully
- [ ] Network failures show appropriate errors
- [ ] App backgrounding doesn't break purchases
- [ ] Subscription expiration handled correctly
- [ ] Restore purchases works
- [ ] Multiple subscription attempts handled

### UI & Performance
- [ ] Trial banner updates correctly
- [ ] Subscription status displays correctly
- [ ] Paywall appears when needed
- [ ] Premium features access controlled correctly
- [ ] App remains stable during rapid changes
- [ ] Memory usage stays reasonable

### Sandbox Specific
- [ ] Multiple accounts work correctly
- [ ] Account switching works
- [ ] Account deletion handled gracefully
- [ ] Account restoration works
- [ ] Receipt validation works with sandbox
- [ ] Debug controls work with sandbox data

---

## Common Issues & Solutions

### Issue: Products Not Loading
**Symptoms**: Products don't appear in subscription screen
**Solutions**:
- Verify product IDs match App Store Connect
- Check sandbox account is signed in
- Ensure products are configured correctly
- Check network connection
- Verify bundle identifier matches

### Issue: Purchase Fails
**Symptoms**: Purchase doesn't complete
**Solutions**:
- Check sandbox account has valid payment method
- Verify product is available in sandbox
- Check network connection
- Try different sandbox account
- Clear App Store cache

### Issue: Subscription Not Activating
**Symptoms**: Purchase succeeds but subscription doesn't activate
**Solutions**:
- Verify receipt validation is working
- Check subscription group configuration
- Ensure proper StoreKit 2 implementation
- Check debug logs for errors
- Verify subscription timer is running

### Issue: Trial Not Starting
**Symptoms**: Trial doesn't start automatically
**Solutions**:
- Check trial logic in SubscriptionManager
- Verify trial timer is started
- Check hasUsedTrial flag
- Ensure trial duration is set correctly
- Check debug logs for trial status

### Issue: Paywall Not Appearing
**Symptoms**: Paywall doesn't appear when trial expires
**Solutions**:
- Check trial expiration logic
- Verify paywall view is configured
- Ensure subscription status is checked
- Check UI state management
- Verify trial banner logic

---

## Debug Commands for Testing

### Start Trial
```swift
subscriptionManager.startTrial()
```

### End Trial
```swift
subscriptionManager.endTrial()
```

### Activate Subscription
```swift
subscriptionManager.activateSubscription()
```

### Cancel Subscription
```swift
subscriptionManager.cancelSubscription()
```

### Reset All
```swift
subscriptionManager.resetTrial()
subscriptionManager.deactivateSubscription()
```

### Restore Purchases
```swift
await subscriptionManager.restorePurchases()
```

---

## Testing Timeline

### Day 1: Basic Functionality
- Test fresh install
- Test trial flow
- Test subscription purchase
- Verify basic functionality

### Day 2: Subscription Management
- Test cancellation
- Test renewal
- Test subscription changes
- Verify management features

### Day 3: Edge Cases
- Test error scenarios
- Test network failures
- Test interrupted purchases
- Verify error handling

### Day 4: UI & Performance
- Test UI updates
- Test performance
- Test stability
- Verify user experience

### Day 5: Sandbox Specific
- Test multiple accounts
- Test account switching
- Test receipt validation
- Verify sandbox behavior

---

**Note**: This comprehensive testing ensures your subscription system works correctly in all scenarios before production release.

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

### Testing with Debug Controls
1. Use **Start 3min Trial** to test trial flow
2. Use **End Trial Now** to test paywall
3. Use **Activate (30 days)** to test subscription
4. Use **Cancel (30 days)** to test cancellation
5. Use **Restore Purchases** to test restore flow

## Phase 6: Verification

### Check Subscription Status
1. In your app, go to **Settings** → **Subscription**
2. Verify subscription status is correct
3. Check expiration date
4. Verify cancellation status if applicable

### Check App Store Connect
1. Go to **App Store Connect** → **Users and Access** → **Sandbox Testers**
2. Check test account status
3. Verify test purchases are recorded
4. Check subscription management

### Check Device Settings
1. Go to **Settings** → **Apple ID** → **Subscriptions**
2. Find your app subscription
3. Verify subscription details
4. Test subscription management

## Troubleshooting

### Common Issues

#### Products Not Loading
- **Problem**: Products don't appear in app
- **Solution**: 
  - Verify product IDs match App Store Connect
  - Check sandbox account is signed in
  - Ensure products are configured correctly
  - Check network connection

#### Purchase Fails
- **Problem**: Purchase doesn't complete
- **Solution**:
  - Check sandbox account has valid payment method
  - Verify product is available in sandbox
  - Check network connection
  - Try different sandbox account

#### Subscription Not Activating
- **Problem**: Subscription doesn't activate after purchase
- **Solution**:
  - Verify receipt validation is working
  - Check subscription group configuration
  - Ensure proper StoreKit 2 implementation
  - Check debug logs

#### Sandbox Account Issues
- **Problem**: Can't sign in with sandbox account
- **Solution**:
  - Verify account is created in App Store Connect
  - Check email and password are correct
  - Ensure account is in correct country
  - Try creating new sandbox account

### Debug Logs to Monitor
```
🛒 Attempting to load products: [com.whio.waterreminder.monthly, com.whio.waterreminder.yearly]
🛒 Successfully loaded 2 products
💳 Purchase successful: com.whio.waterreminder.monthly
🔄 Subscription status updated: Active
🧪 DEBUG: Subscription cancelled - will expire at 2024-11-02 15:30:00 +0000
```

## Phase 7: Production Preparation

### Remove Debug Controls
1. Remove debug controls from production build
2. Set real subscription durations
3. Remove test overrides
4. Test with real users

### Final Testing
1. Test with multiple sandbox accounts
2. Verify all subscription flows
3. Test subscription management
4. Verify receipt validation
5. Test edge cases

### App Store Submission
1. Prepare app screenshots
2. Write app description
3. Submit for review
4. Monitor review process
5. Respond to review feedback

## Best Practices

### Testing
- Test with multiple sandbox accounts
- Test all subscription flows
- Test edge cases and error scenarios
- Verify subscription management
- Test restore purchases functionality

### Development
- Use debug controls for rapid testing
- Monitor debug logs for issues
- Test on multiple devices
- Test with different network conditions
- Verify receipt validation

### Production
- Remove debug controls
- Set real subscription durations
- Test with real users
- Monitor subscription metrics
- Respond to user feedback

## Resources

### Apple Documentation
- [StoreKit 2 Documentation](https://developer.apple.com/documentation/storekit)
- [In-App Purchase Guide](https://developer.apple.com/in-app-purchase/)
- [App Store Connect Help](https://help.apple.com/app-store-connect/)

### Testing Tools
- Xcode StoreKit Testing
- App Store Connect Sandbox
- Device Settings
- Debug Controls

### Support
- Apple Developer Forums
- App Store Connect Support
- StoreKit Documentation
- Community Resources

---

**Note**: Sandbox testing uses real App Store infrastructure but doesn't charge real money. This is the closest you can get to production testing before release.

**Important**: Always test thoroughly in sandbox before submitting to production. Sandbox testing helps identify issues early and ensures a smooth user experience.
