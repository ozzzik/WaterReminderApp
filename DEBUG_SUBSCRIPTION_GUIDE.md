# Debug Subscription Guide

## Quick Test Steps

### 1. Open the App
- Launch Water Reminder on your device

### 2. Check Current Status
- Go to **Settings** → **Subscription**
- Look for one of these:
  - ✅ **"Premium Active"** (green checkmark) - You have an active subscription
  - 🔄 **"Upgrade to Premium"** - No subscription yet
  - ⏰ **Trial countdown** - Free trial is active

### 3. Enable Debug Controls
- In Settings, scroll down to **"Debug Controls"**
- Toggle **"Show Debug Options"** to ON
- You'll see detailed status information

### 4. Test Subscription (Debug Mode)
Use these buttons to test:

#### Trial Management:
- **"Start Trial (3 min)"** - Start a 3-minute trial
- **"End Trial (Paywall)"** - End trial and show paywall
- **"Reset Trial (Allow New Trial)"** - Clear trial data

#### Premium Management:
- **"Activate Subscription (1 min)"** - Simulate premium activation
- **"Deactivate Subscription (Clear All)"** - Remove all subscription data
- **"Cancel Subscription (Active for 1 min)"** - Simulate cancellation

### 5. Check Status After Each Action
After using debug buttons, check:
- **Settings** → **Subscription** for subscription status
- **Main screen** for trial banner changes
- **Debug Controls** for detailed status

## Expected Behavior

### After "Start Trial (3 min)":
- Trial banner appears on main screen
- Shows countdown timer (3:00, 2:59, 2:58...)
- Settings shows trial status

### After "Activate Subscription (1 min)":
- Trial banner disappears
- Settings shows "Premium Active"
- App unlocks premium features

### After "Cancel Subscription":
- Settings shows "Premium Active" but with "Cancelled" label
- Shows "Active until [time]" with countdown
- Red warning about deactivation

## Troubleshooting

### If subscriptions don't show:
1. **Check Debug Controls** - Look at the status indicators
2. **Try "Activate Subscription"** - This simulates a purchase
3. **Check Xcode Console** - Look for error messages

### If trial doesn't work:
1. **Try "Reset Trial"** first
2. **Then "Start Trial (3 min)"**
3. **Check the countdown timer**

### If premium doesn't activate:
1. **Use "Activate Subscription"** debug button
2. **Check Settings** → **Subscription**
3. **Look for "Premium Active" status**

## Console Messages to Look For

In Xcode console, you should see:
- `🛒 Successfully loaded X products`
- `💳 Subscription activated`
- `✅ Premium features unlocked`
- `🆓 Trial started`
- `⏰ Trial time remaining: XX:XX`

## Next Steps After Testing

Once debug testing works:
1. **Sign out** of personal Apple ID on device
2. **Sign in** with sandbox test account
3. **Test real purchases** through the paywall
4. **Verify subscription status** updates correctly


















