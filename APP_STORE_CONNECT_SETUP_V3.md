# 📱 App Store Connect - Complete Setup Guide (v3 Products)

## **🎯 WHAT YOU'RE CREATING:**

Two subscription products with 7-day free trials:
- **Monthly:** `com.whio.waterreminder.monthly.v3` - $0.99/month
- **Yearly:** `com.whio.waterreminder.yearly.v3` - $9.99/year

---

## **📋 STEP-BY-STEP INSTRUCTIONS:**

---

### **STEP 1: Open App Store Connect**

1. **Go to:** https://appstoreconnect.apple.com
2. **Sign in** with your Apple Developer account
3. **Click:** "My Apps" (top of page)
4. **Select:** Your app from the list
   - If you don't have an app yet, click "+" to create one

---

### **STEP 2: Navigate to Subscriptions**

1. **In your app page**, look at the **left sidebar**
2. **Click:** "Subscriptions" (under "Monetization" section)
3. You'll see the subscriptions page

---

### **STEP 3: Create NEW Subscription Group**

**Important:** Create a FRESH group (not the one you made a mistake with)

1. **Click:** Blue "+" button (top left)
2. **Select:** "Create Subscription Group"
3. **Enter details:**
   ```
   Reference Name: Premium Subscriptions v3
   ```
4. **Click:** "Create"

5. **Add Localization:**
   - In the new group, find "Subscription Group Localizations"
   - Click "+" button
   - Select: **English (U.S.)**
   - Enter:
     ```
     Subscription Group Display Name: Premium Features
     Custom App Name: Water Reminder Premium
     ```
   - Click "Save"

---

### **STEP 4: Create Monthly Subscription**

1. **Inside the v3 group**, click **"+"** button (Create Subscription)
2. **You'll see a form. Fill it out:**

#### **Product Information:**
```
Reference Name: Premium Monthly v3
Product ID: com.whio.waterreminder.monthly.v3
```
⚠️ **Important:** Type the Product ID EXACTLY as shown above!

3. **Click:** "Create"

#### **Subscription Duration:**
- **Select:** 1 month (from dropdown)

#### **Subscription Prices:**
1. **Click:** "+" next to "Subscription Prices"
2. **Select:** "United States"
3. **Choose price tier:**
   - Find: **$0.99 USD (Tier 1)**
   - Or manually enter: $0.99
4. **Click:** "Next"
5. **Set availability:**
   - Start Date: Today's date
   - End Date: Leave blank (ongoing)
6. **Click:** "Create"

#### **⭐ ADD 7-DAY FREE TRIAL:**
1. **Still in the Subscription Prices section**
2. **Click on the price you just created** ($0.99)
3. **Scroll down** to find **"Introductory Offers"**
4. **Click:** "Set Up Introductory Offers" or "Create Introductory Offer"
5. **Fill out the form:**
   ```
   Reference Name: 7-Day Free Trial
   Start Date: Today
   End Date: Leave blank
   Offer Type: Free Trial
   Duration: 1 week (7 days)
   ```
6. **Select countries:** Click "Select All Countries and Regions"
7. **Click:** "Save"

#### **Subscription Localization:**
1. **Scroll to:** "Subscription Localizations"
2. **Click:** "+" button
3. **Select:** English (U.S.)
4. **Fill out:**
   ```
   Display Name: Premium Monthly
   Description: Get unlimited access to all premium features with personalized water intake reminders and advanced tracking. Stay hydrated and healthy!
   ```
5. **Click:** "Save"

#### **Review Information:**
- Scroll through and make sure everything looks correct
- **Status:** Should be "Missing Metadata" or "Ready for Review"

6. **Click:** "Save" (top right)

---

### **STEP 5: Create Yearly Subscription**

1. **Back in the v3 subscription group**
2. **Click:** "+" button (Create Subscription)

#### **Product Information:**
```
Reference Name: Premium Yearly v3
Product ID: com.whio.waterreminder.yearly.v3
```
⚠️ **Important:** Type the Product ID EXACTLY as shown above!

3. **Click:** "Create"

#### **Subscription Duration:**
- **Select:** 1 year (from dropdown)

#### **Subscription Prices:**
1. **Click:** "+" next to "Subscription Prices"
2. **Select:** "United States"
3. **Choose price tier:**
   - Find: **$9.99 USD (Tier 10)**
   - Or manually enter: $9.99
4. **Click:** "Next"
5. **Set availability:**
   - Start Date: Today's date
   - End Date: Leave blank (ongoing)
6. **Click:** "Create"

#### **⭐ ADD 7-DAY FREE TRIAL:**
1. **Click on the price you just created** ($9.99)
2. **Scroll down** to find **"Introductory Offers"**
3. **Click:** "Set Up Introductory Offers" or "Create Introductory Offer"
4. **Fill out the form:**
   ```
   Reference Name: 7-Day Free Trial
   Start Date: Today
   End Date: Leave blank
   Offer Type: Free Trial
   Duration: 1 week (7 days)
   ```
5. **Select countries:** Click "Select All Countries and Regions"
6. **Click:** "Save"

#### **Subscription Localization:**
1. **Scroll to:** "Subscription Localizations"
2. **Click:** "+" button
3. **Select:** English (U.S.)
4. **Fill out:**
   ```
   Display Name: Premium Yearly
   Description: Get unlimited access to all premium features with personalized water intake reminders and advanced tracking. Save 17% compared to monthly! Best value for serious hydration tracking.
   ```
5. **Click:** "Save"

6. **Click:** "Save" (top right)

---

### **STEP 6: Configure Subscription Group Settings**

1. **Go back to** your subscription group overview
2. **You should see both subscriptions:**
   - Premium Monthly v3 ($0.99/month)
   - Premium Yearly v3 ($9.99/year)

#### **Set Subscription Ranking:**
1. **Click:** "Subscription Ranking" or "Edit"
2. **Set levels:**
   ```
   Level 1: Premium Monthly v3
   Level 1: Premium Yearly v3
   ```
   ⚠️ **Both at Level 1** - This allows users to switch between them

3. **Click:** "Save"

---

### **STEP 7: Submit for Review**

For each subscription (Monthly and Yearly):

1. **Click on the subscription** (Monthly v3 or Yearly v3)
2. **Scroll to top**
3. **Change Status:**
   - From: "Developer Action Needed" or "Missing Metadata"
   - To: **"Ready to Submit"**
4. **Click:** "Save"

Repeat for the other subscription.

---

### **STEP 8: Verify Everything**

**Check that you have:**
- ✅ Subscription Group: "Premium Subscriptions v3"
- ✅ Monthly Subscription: `com.whio.waterreminder.monthly.v3`
  - ✅ Price: $0.99/month
  - ✅ Introductory Offer: 7-day free trial
  - ✅ Status: Ready to Submit
- ✅ Yearly Subscription: `com.whio.waterreminder.yearly.v3`
  - ✅ Price: $9.99/year
  - ✅ Introductory Offer: 7-day free trial
  - ✅ Status: Ready to Submit
- ✅ Both at Level 1 (can switch between them)

---

## **🎯 VISUAL WALKTHROUGH:**

### **What You'll See on Each Page:**

#### **Subscription Group Page:**
```
Premium Subscriptions v3
├── Premium Monthly v3
│   └── $0.99/month • 7-day free trial
└── Premium Yearly v3
    └── $9.99/year • 7-day free trial
```

#### **Monthly Subscription Page:**
```
Reference Name: Premium Monthly v3
Product ID: com.whio.waterreminder.monthly.v3
Status: Ready to Submit

Subscription Duration: 1 month

Subscription Prices:
└── $0.99 (USD) • All Countries
    └── Introductory Offer: 7-day free trial

Subscription Localizations:
└── English (U.S.)
    ├── Display Name: Premium Monthly
    └── Description: Get unlimited access...
```

#### **Yearly Subscription Page:**
```
Reference Name: Premium Yearly v3
Product ID: com.whio.waterreminder.yearly.v3
Status: Ready to Submit

Subscription Duration: 1 year

Subscription Prices:
└── $9.99 (USD) • All Countries
    └── Introductory Offer: 7-day free trial

Subscription Localizations:
└── English (U.S.)
    ├── Display Name: Premium Yearly
    └── Description: Get unlimited access... Save 17%...
```

---

## **🚨 COMMON MISTAKES TO AVOID:**

### **❌ WRONG Product ID Format:**
```
❌ com.whio.waterreminder.monthly.v2   (old - don't use!)
❌ com.whio.waterreminder.monthlyv3    (missing dot)
❌ com.whio.waterreminder.monthly-v3   (use dot, not dash)
✅ com.whio.waterreminder.monthly.v3   (CORRECT!)
```

### **❌ WRONG Subscription Level:**
```
❌ Monthly: Level 1, Yearly: Level 2  (users can't switch)
✅ Monthly: Level 1, Yearly: Level 1  (users can switch)
```

### **❌ FORGETTING the Free Trial:**
- Each product needs its OWN introductory offer
- Don't skip this step!
- Both monthly AND yearly need the trial

### **❌ WRONG Status:**
```
❌ Missing Metadata
❌ Developer Action Needed
✅ Ready to Submit (for sandbox testing)
```

---

## **⏱️ TIME REQUIRED:**

| Step | Time |
|------|------|
| Create subscription group | 2 minutes |
| Create monthly subscription | 5 minutes |
| Add 7-day trial to monthly | 3 minutes |
| Create yearly subscription | 5 minutes |
| Add 7-day trial to yearly | 3 minutes |
| Verify and save | 2 minutes |
| **TOTAL** | **~20 minutes** |

---

## **✅ AFTER SETUP:**

### **Products Will Be Available In:**
- ✅ **Sandbox immediately** (within 5-10 minutes)
- ✅ **TestFlight immediately** (after upload)
- ⏳ **App Store** (after app review)

### **You Can Test In:**
1. **Xcode Simulator** - Works now with StoreKit config!
2. **Sandbox (Device)** - Available in 5-10 minutes
3. **TestFlight** - Available after you upload

---

## **🎯 CHECKLIST - COPY THIS:**

Print this and check off as you go:

```
□ Step 1: Open App Store Connect
□ Step 2: Navigate to Subscriptions
□ Step 3: Create "Premium Subscriptions v3" group
□ Step 4: Add group localization (English)

Monthly Subscription:
□ Create product: com.whio.waterreminder.monthly.v3
□ Set duration: 1 month
□ Set price: $0.99 USD
□ Add introductory offer: 7-day free trial
□ Add localization: Premium Monthly
□ Set status: Ready to Submit
□ Save

Yearly Subscription:
□ Create product: com.whio.waterreminder.yearly.v3
□ Set duration: 1 year
□ Set price: $9.99 USD
□ Add introductory offer: 7-day free trial
□ Add localization: Premium Yearly
□ Set status: Ready to Submit
□ Save

Final:
□ Set both to Level 1 (Subscription Ranking)
□ Verify both show "Ready to Submit"
□ Verify both have 7-day free trial
□ Done! ✅
```

---

## **🚀 AFTER YOU CREATE THEM:**

### **Test Immediately in Xcode:**
```bash
# Already works with StoreKit config!
open /Users/ohardoon/WaterReminderApp/WaterReminderApp.xcodeproj
# Press Cmd + R
# Products will load from Configuration.storekit
```

### **Test in Sandbox (10 minutes after creation):**
1. Build to device
2. Products will load from App Store Connect
3. Use sandbox tester account
4. Test purchase with 7-day trial

---

## **💡 TIPS:**

### **Product ID Must Match EXACTLY:**
Your app looks for:
- `com.whio.waterreminder.monthly.v3`
- `com.whio.waterreminder.yearly.v3`

Copy-paste these into App Store Connect to avoid typos!

### **7-Day Trial is Standard:**
- Netflix: 7 days
- Spotify: 7 days
- Headspace: 7 days
- Apple Music: 1 month (generous!)

7 days is the industry standard.

### **Sandbox Testing:**
- Trial duration in sandbox: **3 minutes = 7 days** (accelerated!)
- After 3 min: Auto-renews to paid (simulates Day 8)
- Max 6 renewals then expires

---

## **📊 FINAL VERIFICATION:**

After creating both products, your subscription group should look like this:

```
Premium Subscriptions v3
│
├── Premium Monthly v3
│   ├── Product ID: com.whio.waterreminder.monthly.v3
│   ├── Price: $0.99/month
│   ├── Trial: 7 days free
│   ├── Level: 1
│   └── Status: Ready to Submit ✅
│
└── Premium Yearly v3
    ├── Product ID: com.whio.waterreminder.yearly.v3
    ├── Price: $9.99/year
    ├── Trial: 7 days free
    ├── Level: 1
    └── Status: Ready to Submit ✅
```

---

## **🎉 YOU'RE DONE!**

Once you see "Ready to Submit" on both products, you're all set!

**Test in Xcode right now - it already works!** 🚀

**Questions?** Re-read the steps above or check the screenshots in App Store Connect.

---

## **❓ NEED HELP?**

### **Can't find Subscriptions tab?**
- Make sure you selected your app first
- Look in left sidebar under "Monetization"

### **Product ID already exists?**
- Someone else is using it, or
- You created it before - delete it first, or
- Use v4 instead of v3

### **Can't save subscription?**
- Make sure all required fields are filled
- Reference Name, Product ID, Duration, Price
- Add at least one localization

### **Status won't change to "Ready to Submit"?**
- Add at least one price
- Add at least one localization
- Fill in all required fields

---

**Good luck! You got this! 🚀**















