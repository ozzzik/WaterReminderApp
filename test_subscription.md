# Quick Subscription Testing Guide

## 🚀 Fastest Way to Test (5 minutes)

1. **Run in Xcode Simulator**
2. **Go to Settings → Subscription**
3. **Use these debug buttons**:

### Test Scenarios:
- **Fresh Start**: Tap "Reset Trial" → App restarts trial
- **Trial Active**: Tap "Start Trial" → See trial banner and full access
- **Trial Expired**: Tap "End Trial" → App locks, shows paywall
- **Premium User**: Tap "Activate Premium" → Full access, no paywall
- **Back to Trial**: Tap "Deactivate Premium" + "Start Trial"

## 🧪 StoreKit Testing (10 minutes)

1. **Configure Xcode**:
   - Edit Scheme → Run → Options
   - StoreKit Configuration → Select "Configuration.storekit"

2. **Test Purchase Flow**:
   - Run in simulator
   - Try to add water → Paywall appears
   - Tap Subscribe → See monthly/yearly options
   - Purchase (fake) → App unlocks
   - Check Settings → Shows "Premium Active"

## 📱 Device Testing (15 minutes)

1. **Create Sandbox Account**:
   - App Store Connect → Users and Access → Sandbox Testers
   - Create test account (use different email)

2. **Test on Device**:
   - Sign out of App Store
   - Sign in with sandbox account
   - Install app and test purchases

## ✅ Testing Checklist

- [ ] Trial starts automatically on first launch
- [ ] Trial countdown shows correct days remaining  
- [ ] App blocks usage after trial expires
- [ ] Paywall appears when trial expires
- [ ] Subscription purchase works
- [ ] Premium access restored after purchase
- [ ] App handles subscription cancellation
- [ ] All subscription statuses display correctly

## 🐛 Debug Logs to Watch

Look for these in Xcode console:
- `🆓 Trial started: [date]`
- `🧪 DEBUG: Simulated [action]`
- `💳 Subscription status: [status]`
- `❌ [error messages]`

## 🎯 Key Test Points

1. **Trial Banner**: Should show during trial period
2. **Water Logging**: Blocked without subscription/trial
3. **Paywall**: Appears when trying to use locked features
4. **Settings**: Shows correct subscription status
5. **Purchase Flow**: Smooth transaction experience
