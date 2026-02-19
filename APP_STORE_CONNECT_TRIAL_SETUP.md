# 🎯 App Store Connect - Free Trial Setup Guide

## **APPLE'S FREE TRIAL (7 Days)**

Your app now uses **Apple's built-in free trial system**. This is the modern, industry-standard approach used by Spotify, Headspace, Calm, and most subscription apps.

---

## **✅ WHAT YOU GET:**

### **User Experience:**
1. User taps "Start Free Trial" in your app
2. **Apple shows:** "Start 7-day free trial, then $0.99/month"
3. User confirms with Face ID/Touch ID
4. **User gets immediate access** (7 days full premium)
5. **Day 7:** Apple sends "Trial ending soon" notification
6. **Day 8:** Apple charges $0.99, subscription continues
7. **User can cancel anytime** in iOS Settings (no charge if during trial)

### **Benefits:**
- ✅ **Apple handles everything** (no trial tracking bugs!)
- ✅ **Auto-converts to paid** (higher conversion rate!)
- ✅ **Industry standard** (users expect it!)
- ✅ **No phantom subscriptions** (clean StoreKit2!)
- ✅ **Automatic notifications** (Apple reminds users!)

---

## **📋 SETUP IN APP STORE CONNECT**

### **Step 1: Go to App Store Connect**

1. **Visit:** https://appstoreconnect.apple.com
2. **Sign in** with your Apple Developer account
3. **Click:** My Apps
4. **Select:** Your app (or create if new)

---

### **Step 2: Create Subscription Group**

1. **In your app:** Click **"Subscriptions"** tab (left sidebar)
2. **Click:** "+" button (Create Subscription Group)
3. **Enter details:**
   ```
   Reference Name: Premium Subscriptions v2
   App Name: Water Reminder Premium
   ```
4. **Click:** Create

---

### **Step 3: Create Monthly Subscription with 7-Day Free Trial**

1. **In the subscription group:** Click "+" button (Create Subscription)
2. **Enter Product Information:**
   ```
   Reference Name: Premium Monthly v2
   Product ID: com.whio.waterreminder.monthly.v2
   ```
3. **Click:** Create

4. **Subscription Duration:**
   - Select: **1 month**

5. **Subscription Price:**
   ```
   Price: $0.99 USD
   (Or select your preferred price tier)
   ```

6. **Subscription Localizations:**
   - Click "+" next to Subscription Localizations
   - Select: English (U.S.)
   - Enter:
     ```
     Display Name: Premium Monthly
     Description: Monthly premium subscription with unlimited access to all features and personalized hydration reminders.
     ```
   - Click: Save

7. **⭐ ADD FREE TRIAL (Important!):**
   - Scroll to **"Subscription Prices"** section
   - Click on the price you just added ($0.99)
   - Find **"Introductory Offer"** section
   - Click **"Create Introductory Offer"**
   - Select offer type: **"Free Trial"**
   - Enter details:
     ```
     Duration: 7 days
     Countries: All countries and regions
     Start Date: Today
     ```
   - Click: Save

8. **Set Subscription to Ready:**
   - Scroll to top
   - Status: Change to **"Ready to Submit"**
   - Click: Save

---

### **Step 4: Create Yearly Subscription with 7-Day Free Trial**

1. **In the same subscription group:** Click "+" (Create Subscription)
2. **Enter Product Information:**
   ```
   Reference Name: Premium Yearly v2
   Product ID: com.whio.waterreminder.yearly.v2
   ```
3. **Click:** Create

4. **Subscription Duration:**
   - Select: **1 year**

5. **Subscription Price:**
   ```
   Price: $9.99 USD
   (Or select your preferred price tier)
   ```

6. **Subscription Localizations:**
   - Click "+" next to Subscription Localizations
   - Select: English (U.S.)
   - Enter:
     ```
     Display Name: Premium Yearly
     Description: Annual premium subscription with unlimited access to all features. Save 17% compared to monthly subscription.
     ```
   - Click: Save

7. **⭐ ADD FREE TRIAL (Important!):**
   - Scroll to **"Subscription Prices"** section
   - Click on the price you just added ($9.99)
   - Find **"Introductory Offer"** section
   - Click **"Create Introductory Offer"**
   - Select offer type: **"Free Trial"**
   - Enter details:
     ```
     Duration: 7 days
     Countries: All countries and regions
     Start Date: Today
     ```
   - Click: Save

8. **Set Subscription to Ready:**
   - Scroll to top
   - Status: Change to **"Ready to Submit"**
   - Click: Save

---

### **Step 5: Configure Subscription Group Settings**

1. **Back in the subscription group view**
2. **Set Subscription Levels:**
   - Both subscriptions should be at **Level 1** (same level)
   - This allows users to upgrade/downgrade between them

3. **Review Settings:**
   - ✅ Monthly: $0.99/month with 7-day free trial
   - ✅ Yearly: $9.99/year with 7-day free trial
   - ✅ Both in same group
   - ✅ Both marked "Ready to Submit"

---

## **🧪 TESTING IN XCODE (StoreKit Configuration)**

### **Already Set Up! ✅**

Your `Configuration.storekit` file already has:
- ✅ Product IDs: `*.monthly.v2` and `*.yearly.v2`
- ✅ Free trial: 7 days (P1W)
- ✅ Ready to test locally

### **Test Now:**

```bash
# Open in Xcode
open /Users/ohardoon/WaterReminderApp/WaterReminderApp.xcodeproj

# Press Cmd + R
# App launches in Simulator
# Tap "Start Free Trial"
# Apple's purchase sheet shows: "Start 7-day free trial, then $0.99/month"
```

---

## **🎯 HOW APPLE'S TRIAL WORKS:**

### **Purchase Flow:**
1. User taps "Start Free Trial" button
2. **Apple's sheet appears** showing:
   ```
   Start 7-day free trial
   Then $0.99/month
   
   [Subscribe with Face ID/Touch ID button]
   
   Free for 7 days, then $0.99/month.
   Cancel anytime.
   ```
3. User confirms with Face ID
4. **Subscription created immediately**
5. **Trial period starts** (7 days)
6. **Your app sees:** `subscriptionStatus = .subscribed` ✅
7. **User has full access** immediately

### **What Happens Next:**
- **During 7 days:** User has full premium access
- **Day 7:** Apple sends notification "Trial ending in 1 day"
- **Day 8:** Apple charges $0.99, subscription continues
- **User can cancel:** iOS Settings → Subscriptions (no charge if before Day 8)

---

## **🔍 CHECKING TRIAL STATUS IN YOUR APP:**

### **How to Detect Trial:**

```swift
// In SubscriptionManager.swift - updateSubscriptionStatus()
for await result in Transaction.currentEntitlements {
    let transaction = try checkVerified(result)
    
    // Check if user is in trial period
    if let product = products.first(where: { $0.id == transaction.productID }) {
        // Check for introductory offer
        if transaction.offerType == .introductory {
            print("🎉 User is in FREE TRIAL period!")
            // User is in 7-day free trial
        } else {
            print("💰 User is PAYING subscriber")
            // User is paying (after trial ended)
        }
    }
}
```

**Note:** For your app, both trial users and paying users have `isPremiumActive = true`. You don't need to differentiate - both get full access!

---

## **📊 TESTING SCENARIOS:**

### **Xcode Testing (StoreKit Config):**
1. Run in Simulator
2. Tap "Start Free Trial"
3. Confirm purchase in simulator
4. **App sees:** subscriptionStatus = .subscribed
5. **User has:** Full premium access immediately
6. **Trial countdown:** Simulated by StoreKit config

### **Sandbox Testing (Device):**
1. Build to device
2. Sign in with sandbox tester
3. Tap "Start Free Trial"
4. Confirm purchase
5. **Trial duration:** 3 minutes = 7 days (accelerated!)
6. **After 3 min:** Auto-renews (simulates Day 8)
7. **Max 6 renewals** then expires

### **TestFlight/Production:**
1. Real 7-day trial
2. Real auto-renewal on Day 8
3. Real Apple notifications
4. Users can cancel in Settings

---

## **🚨 IMPORTANT NOTES:**

### **Trial Eligibility:**
- ✅ **First-time users:** Get 7-day free trial
- ❌ **Previous subscribers:** No trial (Apple tracks this)
- ❌ **Cancelled and resubscribe:** No trial (one per user per subscription group)

### **Sandbox Testing:**
- **Accelerated timing:** 3 minutes = 7 days
- **Auto-renews:** Every 3-5 minutes (simulates monthly renewal)
- **Max renewals:** 6 times, then expires
- **Trial resets:** When you clear purchase history in App Store Connect

---

## **📝 SUMMARY:**

### **What You Did:**
1. ✅ Removed app-based trial code (no more bugs!)
2. ✅ Updated app to use Apple's trial system
3. ✅ Configured StoreKit config with trials

### **What You Need to Do:**
1. ⏳ Create products in App Store Connect (follow steps above)
2. ⏳ Add 7-day free trial to both products
3. ⏳ Mark both as "Ready to Submit"

### **Result:**
- ✅ Professional trial system (like Spotify, Netflix, etc.)
- ✅ Higher conversion rate (auto-renews)
- ✅ Apple handles everything (no bugs!)
- ✅ Clean, production-ready code

---

## **🎉 YOU'RE READY!**

**The app code is complete. Just set up the products in App Store Connect following the steps above!**

**Test in Xcode right now - it already works with the StoreKit config file!** 🚀















