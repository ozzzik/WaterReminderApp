# 🔍 Receipt Verification Guide

## **Purpose**
This guide helps you debug subscription issues by verifying the actual App Store receipt data to confirm what's happening with your subscriptions.

---

## **🎯 WHAT WE'RE CHECKING:**

### **Key Receipt Fields:**
- **`isInBillingRetryPeriod`** - Should be `false` for normal operation
- **`isTrialPeriod`** - Should be `true` during 7-day free trial
- **`expiresDate`** - Should match your sandbox renewal schedule
- **`productId`** - Should show your v3 product IDs
- **`originalTransactionId`** - Unique identifier for the subscription

---

## **🚀 HOW TO USE:**

### **Step 1: Build and Run**
```bash
# Build the app with receipt verification
xcodebuild -project WaterReminderApp.xcodeproj -scheme WaterReminderApp -destination 'platform=iOS Simulator,name=iPhone 16' build
```

### **Step 2: Test in Your Environment**
1. **Open the app**
2. **Go to Settings**
3. **Scroll to "Debug Controls"** (only visible in Xcode builds)
4. **Tap "🔍 Verify Receipt"**

### **Step 3: Check the Results**
The app will display:
- **Receipt verification data** in the Settings screen
- **Console output** with detailed information
- **Real-time subscription status** from Apple's servers

---

## **🔍 WHAT TO LOOK FOR:**

### **✅ NORMAL SANDBOX SUBSCRIPTION:**
```
isInBillingRetryPeriod: false
isTrialPeriod: true (during trial)
expiresDate: [Date matching your sandbox schedule]
productId: com.whio.waterreminder.monthly.v3
originalTransactionId: [Unique ID]
```

### **❌ PHANTOM SUBSCRIPTION ISSUES:**
```
isInBillingRetryPeriod: true (billing retry)
isTrialPeriod: false (not in trial)
expiresDate: [Wrong date or nil]
productId: [Old v1/v2 product ID]
originalTransactionId: [Old transaction ID]
```

---

## **🎯 TESTING SCENARIOS:**

### **Scenario 1: Fresh Subscription (Expected)**
- **Purchase** a new subscription
- **Verify receipt** immediately
- **Should show:** `isTrialPeriod: true`, correct product ID, proper expiration

### **Scenario 2: Phantom Subscription (Problem)**
- **If you see** old product IDs (v1/v2)
- **If you see** `isInBillingRetryPeriod: true`
- **If you see** wrong expiration dates
- **This confirms** a phantom subscription issue

### **Scenario 3: StoreKit Configuration Conflict**
- **If you see** local test data instead of real App Store data
- **If you see** `Configuration.storekit` product IDs
- **This confirms** StoreKit Configuration is still interfering

---

## **🔧 TROUBLESHOOTING:**

### **Issue: Still seeing old product IDs**
**Solution:** The phantom subscription is still active. Use the v4 product ID approach.

### **Issue: Receipt shows local test data**
**Solution:** StoreKit Configuration is still enabled. Check Xcode scheme settings.

### **Issue: No receipt data at all**
**Solution:** No active subscription. This is normal for new users.

---

## **📱 TESTING ENVIRONMENTS:**

| Environment | Receipt Source | What to Expect |
|-------------|----------------|----------------|
| **Xcode Simulator** | StoreKit Configuration | Local test data |
| **TestFlight** | App Store Connect | Real subscription data |
| **Sandbox Device** | App Store Connect | Real subscription data |

---

## **🎯 NEXT STEPS:**

1. **Run receipt verification** in your current environment
2. **Check the results** against the expected values above
3. **Identify the issue** based on what you see
4. **Apply the appropriate fix** based on the troubleshooting guide

---

## **✅ SUCCESS INDICATORS:**

- **`isInBillingRetryPeriod: false`** ✅
- **`isTrialPeriod: true`** (during trial) ✅
- **`productId`** shows v3 products ✅
- **`expiresDate`** matches sandbox schedule ✅

**If all these are correct, your subscription system is working properly!** 🎉















