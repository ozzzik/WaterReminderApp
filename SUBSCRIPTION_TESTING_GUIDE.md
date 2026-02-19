# Subscription Testing Guide

## Quick Start

### 1. Create Sandbox Test Account in App Store Connect
1. **Go to App Store Connect** → [appstoreconnect.apple.com](https://appstoreconnect.apple.com)
2. **Navigate to Users and Access** → **Sandbox Testers**
3. **Click the "+" button** to add a new sandbox tester
4. **Fill in the required information:**
   - **First Name**: Test
   - **Last Name**: User
   - **Email**: Use a unique email (e.g., `testuser+waterreminder@example.com`)
   - **Password**: Create a strong password
   - **Confirm Email**: Same as email
   - **Country/Region**: Select your region
5. **Click "Invite"** to create the sandbox account
6. **Note down the credentials** for device testing

### 2. Sign Out of Personal Apple ID on Test Device
1. **Open Settings** on your iOS device
2. **Tap your name** at the top
3. **Scroll down and tap "Sign Out"**
4. **Enter your Apple ID password** when prompted
5. **Choose what data to keep** (select "Keep on My iPhone" for testing)
6. **Tap "Sign Out"** to confirm

### 3. Sign In with Sandbox Account
1. **Open Settings** → **Sign in to your iPhone**
2. **Enter the sandbox test account email and password**
3. **Complete the sign-in process**
4. **Verify the account is signed in** (should show the test account name)

### 4. Set StoreKit Configuration in Xcode Scheme
1. **Open Xcode** and select your project
2. **Go to Product** → **Scheme** → **Edit Scheme**
3. **Select "Run"** from the left sidebar
4. **Go to "Options" tab**
5. **Under "StoreKit Configuration"**, select your `.storekit` file
6. **Click "Close"** to save the scheme

### 5. Build and Run on Device
1. **Connect your iOS device** to your Mac
2. **Select your device** as the build destination in Xcode
3. **Build and run** the app (⌘+R)
4. **Trust the developer certificate** if prompted on the device
5. **Launch the app** and verify it's running

## Testing Scenarios

### Scenario 1: Free Trial Flow
1. **Launch the app** (should show trial banner)
2. **Verify trial countdown** is running (3 minutes)
3. **Use app features** during trial
4. **Wait for trial to expire** or use "End Trial" debug button
5. **Verify paywall appears** after trial ends
6. **Check notifications are disabled** after trial expires

### Scenario 2: Subscription Purchase Flow
1. **Start from trial or paywall state**
2. **Tap "Subscribe" or "Upgrade" button**
3. **Select subscription plan** (Monthly: $1.99/1min, Yearly: $9.99/10min)
4. **Complete purchase** using sandbox account
5. **Verify premium features unlock**
6. **Check settings show "Premium Active"**
7. **Verify trial stops** when premium activates

### Scenario 3: Subscription Cancellation Flow
1. **Activate subscription** (using debug button or purchase)
2. **Use "Cancel Subscription" debug button**
3. **Verify "Subscription Cancelled" status** appears
4. **Check grace period countdown** (1 minute)
5. **Wait for expiration** or use "Deactivate Subscription"
6. **Verify app returns to paywall state**

### Scenario 4: Subscription Management
1. **With active subscription**, go to Settings
2. **Tap "Manage Subscription"** button
3. **Verify App Store subscription page opens**
4. **Test subscription management** (cancel, resubscribe, etc.)

### Scenario 5: Debug Controls Testing
1. **Open Settings** → **Debug Controls** section
2. **Test each debug button:**
   - **Start Trial**: Resets trial to 3 minutes
   - **End Trial**: Immediately ends trial, shows paywall
   - **Reset Trial**: Clears trial data, allows fresh trial
   - **Activate Subscription**: Simulates successful purchase
   - **Cancel Subscription**: Simulates cancellation with grace period
   - **Deactivate Subscription**: Removes all subscription data

## StoreKit Configuration

### Required Products
Ensure your `.storekit` file includes:

```json
{
  "identifier": "com.whio.waterreminder.monthly",
  "referenceName": "Monthly Premium",
  "productId": "com.whio.waterreminder.monthly",
  "type": "RecurringSubscription",
  "subscriptionPeriod": "P1M",
  "subscriptionPeriodUnit": "month"
},
{
  "identifier": "com.whio.waterreminder.yearly", 
  "referenceName": "Yearly Premium",
  "productId": "com.whio.waterreminder.yearly",
  "type": "RecurringSubscription",
  "subscriptionPeriod": "P1Y",
  "subscriptionPeriodUnit": "year"
}
```

### Testing Durations
- **Trial**: 3 minutes (for quick testing)
- **Monthly Subscription**: 1 minute (for quick testing)
- **Yearly Subscription**: 10 minutes (for quick testing)

## Common Issues & Solutions

### Issue: "No Products Available"
**Solution:**
- Verify StoreKit configuration file is selected in scheme
- Check product IDs match exactly in code and configuration
- Ensure device is signed in with sandbox account

### Issue: "Purchase Failed"
**Solution:**
- Verify sandbox account is properly set up
- Check internet connection
- Try signing out and back in with sandbox account

### Issue: "Subscription Not Activating"
**Solution:**
- Check debug logs for StoreKit errors
- Verify subscription status checking logic
- Test with debug "Activate Subscription" button

### Issue: "Trial Not Resetting"
**Solution:**
- Use "Reset Trial" debug button
- Check UserDefaults are being cleared properly
- Verify trial state management logic

## Debug Logging

The app includes comprehensive debug logging. Look for these log messages:

- `🆓 Trial started` - Trial activation
- `🆓 Trial ended` - Trial expiration
- `💳 Subscription activated` - Premium activation
- `🧪 DEBUG: Subscription cancelled` - Subscription cancellation
- `🛑 Premium activated - stopping trial` - Trial stops when premium activates

## Testing Checklist

- [ ] Sandbox account created and signed in
- [ ] StoreKit configuration set in Xcode scheme
- [ ] App builds and runs on device
- [ ] Trial countdown works correctly
- [ ] Trial expires and shows paywall
- [ ] Subscription purchase completes successfully
- [ ] Premium features unlock after purchase
- [ ] Subscription cancellation shows grace period
- [ ] Subscription expires after grace period
- [ ] Debug controls work as expected
- [ ] Notifications are disabled after trial expires
- [ ] App state persists correctly across launches

## Production Considerations

Before submitting to App Store:

1. **Remove debug controls** (they're already wrapped in `#if DEBUG`)
2. **Set real subscription durations** (1 month, 1 year)
3. **Test with real App Store sandbox** (not just debug buttons)
4. **Verify all edge cases** work correctly
5. **Test subscription restoration** after app reinstall
6. **Verify receipt validation** works properly

## Support

If you encounter issues during testing:

1. **Check Xcode console** for error messages
2. **Verify StoreKit configuration** is correct
3. **Test with debug buttons** to isolate issues
4. **Check device logs** for StoreKit errors
5. **Verify sandbox account** is properly configured

---

**Note**: This guide is specifically for testing the Water Reminder App subscription functionality. The debug controls and test durations are designed for rapid testing and should not be used in production.