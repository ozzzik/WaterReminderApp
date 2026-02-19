# 🧪 Sandbox Testing Guide - Water Reminder App

## 📋 Pre-Testing Checklist

### ✅ StoreKit Configuration
- [x] Product IDs match App Store Connect: `com.whio.waterreminder.monthly` & `com.whio.waterreminder.yearly`
- [x] StoreKit configuration file is properly set up
- [x] Subscription groups configured correctly

### ✅ App Configuration
- [x] Trial duration set to 3 minutes for quick testing
- [x] Debug controls available in settings
- [x] Trial banner shows countdown and expiration states
- [x] Notifications disable automatically when trial expires

## 🚀 Sandbox Testing Setup

### 1. **Create Sandbox Test Account**
1. Go to [App Store Connect](https://appstoreconnect.apple.com)
2. Navigate to **Users and Access** → **Sandbox Testers**
3. Create a new sandbox tester account:
   - Use a unique email (e.g., `test+waterreminder@yourdomain.com`)
   - Choose a country/region
   - Set a password

### 2. **Configure Xcode for Sandbox**
1. In Xcode, go to **Product** → **Scheme** → **Edit Scheme**
2. Select **Run** → **Options**
3. Set **StoreKit Configuration** to your `Configuration.storekit` file
4. This enables local StoreKit testing

### 3. **Device Setup**
1. **Sign out** of your personal Apple ID on the test device
2. Go to **Settings** → **App Store**
3. Sign in with your **sandbox test account**
4. Install the app from Xcode

## 🧪 Testing Scenarios

### **Scenario 1: Fresh Install - Trial Flow**
1. **Install app** on device with sandbox account
2. **Expected**: Trial banner shows "Start Free Trial"
3. **Tap "Get Started"** → Should start 3-minute trial
4. **Expected**: Banner shows countdown "2:59 remaining"
5. **Wait 3 minutes** or use "End Trial Now" debug button
6. **Expected**: Banner shows "Trial Expired - Upgrade to Continue"
7. **Expected**: Notifications are disabled
8. **Expected**: Only 1 cup button is enabled

### **Scenario 2: Purchase Flow**
1. **Start trial** (or use "Start Trial" debug button)
2. **Tap "Upgrade"** in trial banner
3. **Expected**: PaywallView opens
4. **Select Monthly/Yearly** subscription
5. **Complete purchase** with sandbox account
6. **Expected**: Trial banner disappears
7. **Expected**: All features unlocked
8. **Expected**: Notifications can be enabled

### **Scenario 3: Restore Purchases**
1. **After purchase**, go to Settings
2. **Use "Deactivate Premium"** debug button
3. **Expected**: Back to trial expired state
4. **Tap "Restore Purchases"** in paywall
5. **Expected**: Premium reactivated
6. **Expected**: All features unlocked again

### **Scenario 4: Trial Restart**
1. **After trial expires**, go to Settings
2. **Use "Restart Trial"** debug button
3. **Expected**: Banner shows "Start Free Trial" again
4. **Tap "Get Started"** → New 3-minute trial starts

## 🔍 Debug Controls Testing

### **Trial Management**
- **Start Trial**: Should immediately show countdown
- **End Trial Now**: Should show "Trial Expired" immediately
- **Restart Trial**: Should reset to "Start Free Trial" state
- **Reset Trial**: Should clear all trial data

### **Premium Management**
- **Activate Premium**: Should hide trial banner completely
- **Deactivate Premium**: Should show trial expired state

### **System Controls**
- **Force Status Check**: Should refresh subscription status
- **Clear Purchase Cache**: Should clear recent purchase fallback

## 📊 Expected Console Output

### **Trial Start**
```
🆓 Trial started: [timestamp]
🆓 Trial usage check - hasUsedTrial: true
🆓 Trial check - Start: [timestamp], Elapsed: 0.0 minutes, Remaining: 3.0 minutes
🆓 Trial active: 3.0 minutes remaining
```

### **Trial Expiration**
```
🆓 Trial check - Start: [timestamp], Elapsed: 3.0 minutes, Remaining: 0.0 minutes
🆓 Trial expired
🔔 Trial expired - disabling notifications
🔔 Notifications disabled due to trial expiration
```

### **Purchase Success**
```
🛒 Starting purchase for product: com.whio.waterreminder.monthly
✅ Purchase successful, verifying transaction...
✅ Transaction verified: [transaction_id]
💳 Updated subscription status: true
```

## 🐛 Common Issues & Solutions

### **Issue: "No products found"**
- **Solution**: Ensure StoreKit configuration is selected in Xcode scheme
- **Solution**: Check product IDs match exactly

### **Issue: Trial doesn't start automatically**
- **Solution**: Use "Start Trial" debug button
- **Solution**: Check console for trial status logs

### **Issue: Purchase fails**
- **Solution**: Ensure sandbox account is signed in
- **Solution**: Check App Store Connect for product status

### **Issue: UI doesn't update after purchase**
- **Solution**: Use "Force Status Check" debug button
- **Solution**: Check console for subscription status logs

## 📱 Testing Checklist

### **Trial Flow**
- [ ] Fresh install shows "Start Free Trial"
- [ ] Trial starts with 3-minute countdown
- [ ] Countdown updates every second
- [ ] Trial expires and shows "Trial Expired"
- [ ] Notifications disabled when trial expires
- [ ] Only 1 cup button enabled when trial expired

### **Purchase Flow**
- [ ] Paywall opens from trial banner
- [ ] Monthly subscription purchase works
- [ ] Yearly subscription purchase works
- [ ] Premium features unlock after purchase
- [ ] Trial banner disappears after purchase

### **Restore Flow**
- [ ] Restore purchases works
- [ ] Premium status restored correctly
- [ ] All features remain unlocked

### **Debug Controls**
- [ ] All debug buttons work correctly
- [ ] UI updates immediately after debug actions
- [ ] Console logs show expected output

## 🎯 Success Criteria

✅ **Trial System**: 3-minute trial works with countdown and expiration
✅ **Purchase System**: Real StoreKit purchases work in sandbox
✅ **Restore System**: Purchases can be restored
✅ **UI Updates**: All UI updates work correctly
✅ **Notifications**: Properly enabled/disabled based on subscription status
✅ **Debug Tools**: All debug controls work for testing

## 🚀 Next Steps After Testing

1. **Fix any issues** found during testing
2. **Increase trial duration** back to 7 days for production
3. **Remove debug controls** for App Store submission
4. **Test on TestFlight** with external testers
5. **Submit for App Store review**

---

**Happy Testing! 🎉**

Remember to test thoroughly in sandbox before submitting to the App Store. The 3-minute trial duration makes testing much faster!

















