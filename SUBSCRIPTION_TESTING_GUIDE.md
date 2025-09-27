# Subscription Testing Guide

## 🧪 Testing with Debug Controls

### Quick Testing (Debug Mode)
1. **Build and run the app in Debug mode**
2. **Go to Settings** → Scroll to "Subscription" section
3. **Use the test controls** (only visible in Debug builds):
   - **Start Trial** - Reset to beginning of 7-day trial
   - **End Trial** - Simulate trial expiration (app will be locked)
   - **Activate Premium** - Simulate successful subscription
   - **Reset Trial** - Clear trial data completely
   - **Deactivate Premium** - Simulate subscription cancellation

### Test Scenarios
1. **Fresh Install** → Should start 7-day trial automatically
2. **Trial Active** → App fully functional with countdown banner
3. **Trial Expired** → App locked, paywall shown
4. **Premium Active** → App fully functional, no paywall

---

## 🍎 Testing with Real Apple Subscriptions

### Method 1: StoreKit Configuration (Recommended)
1. **Open Xcode** → Select your project
2. **Add StoreKit Configuration File**:
   - Right-click project → "Add Files to WaterReminderApp"
   - Select `Configuration.storekit` from project root
   - Make sure it's added to the target

3. **Configure Scheme for Testing**:
   - Edit Scheme → Run → Options
   - Set "StoreKit Configuration" to "Configuration.storekit"

4. **Test Purchase Flow**:
   - Run app in simulator
   - Go to Settings → Subscription
   - Tap "Upgrade" to see subscription screen
   - Test purchase flow (won't charge real money)

### Method 2: Sandbox Testing
1. **Create Sandbox Test Account**:
   - Go to App Store Connect
   - Users and Access → Sandbox Testers
   - Create new test account

2. **Configure Device**:
   - Sign out of App Store on device/simulator
   - Sign in with sandbox test account

3. **Test Real Purchases**:
   - Make purchases (won't charge real money)
   - Test subscription renewals
   - Test cancellation flows

### Method 3: TestFlight Testing
1. **Upload to TestFlight**:
   - Archive and upload build
   - Add internal/external testers

2. **Test with Real Users**:
   - Testers get real subscription experience
   - Test cancellation and renewal
   - Gather feedback on paywall

---

## 🔧 StoreKit Configuration Setup

### Product IDs
- **Monthly**: `com.whio.waterreminder.monthly` ($1.00)
- **Yearly**: `com.whio.waterreminder.yearly` ($10.00)

### App Store Connect Setup
1. **Create Subscription Group**:
   - Go to App Store Connect → Your App
   - Features → In-App Purchases
   - Create new subscription group "Premium"

2. **Add Products**:
   - Add monthly subscription ($1.00/month)
   - Add yearly subscription ($10.00/year)
   - Use exact product IDs from code

3. **Configure Pricing**:
   - Set prices for all territories
   - Add localizations for descriptions

### Testing Checklist
- [ ] Trial starts automatically on first launch
- [ ] Trial countdown shows correct days remaining
- [ ] App blocks usage after trial expires
- [ ] Paywall appears when trial expires
- [ ] Subscription purchase works
- [ ] Premium access restored after purchase
- [ ] Restore purchases works
- [ ] App handles subscription cancellation
- [ ] App handles subscription renewal

---

## 🐛 Common Issues & Solutions

### Issue: "No products found"
**Solution**: 
- Check product IDs match App Store Connect
- Ensure StoreKit configuration is loaded
- Verify app is signed with correct team

### Issue: "Purchase failed"
**Solution**:
- Check sandbox account is signed in
- Verify subscription group is configured
- Ensure products are approved in App Store Connect

### Issue: "Trial not starting"
**Solution**:
- Check UserDefaults key consistency
- Verify `startTrial()` is called on app launch
- Check debug logs for trial status

### Issue: "App not locking after trial"
**Solution**:
- Verify `canUseApp()` logic
- Check trial status calculation
- Ensure paywall is shown when needed

---

## 📊 Testing Metrics

### Key Metrics to Track
- **Trial-to-Paid Conversion Rate**
- **Purchase Success Rate**
- **Restore Success Rate**
- **Paywall Engagement**
- **Subscription Retention**

### Debug Logs
The app includes comprehensive logging:
- `🆓 Trial started`
- `💳 Subscription status: Active/Inactive`
- `🧪 DEBUG: [test action]`
- `❌ [error messages]`

Check Xcode console for detailed logs during testing.

---

## 🚀 Production Checklist

Before releasing to App Store:
- [ ] Remove all debug test buttons
- [ ] Test with real App Store sandbox
- [ ] Verify product IDs match App Store Connect
- [ ] Test restore purchases flow
- [ ] Verify trial logic works correctly
- [ ] Test subscription cancellation
- [ ] Check all localizations
- [ ] Verify pricing in all territories
