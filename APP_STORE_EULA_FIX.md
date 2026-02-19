# 🔧 App Store Rejection Fix - EULA Requirements

## ✅ WHAT WAS FIXED IN YOUR APP

Your app now includes **functional EULA links** in all subscription screens:

### 1. **PaywallView** (Initial Subscription Screen)
- ✅ Privacy Policy link: `https://ozzzik.github.io/WaterReminderApp/privacy-policy.html`
- ✅ Terms of Use (EULA) link: `https://www.apple.com/legal/internet-services/itunes/dev/stdeula/`

### 2. **SubscriptionView** (Upgrade Screen)
- ✅ Privacy Policy link: `https://ozzzik.github.io/WaterReminderApp/privacy-policy.html`
- ✅ Terms of Use (EULA) link: `https://www.apple.com/legal/internet-services/itunes/dev/stdeula/`

### 3. **SettingsView** (About Section)
- ✅ Privacy Policy link: `https://ozzzik.github.io/WaterReminderApp/privacy-policy.html`
- ✅ Terms of Use (EULA) link: `https://www.apple.com/legal/internet-services/itunes/dev/stdeula/`

---

## 📝 REQUIRED APP STORE CONNECT CHANGES

Apple requires you to **also update your App Store Connect metadata**. Follow these steps:

### Step 1: Update Your App Description

Go to **App Store Connect → Your App → App Information → App Description**

Add this paragraph at the **bottom** of your app description:

```
SUBSCRIPTION INFORMATION

Premium Monthly: $0.99/month - Unlimited reminders and custom intervals
Premium Yearly: $9.99/year - Save 17% with annual billing

Payment will be charged to your Apple ID account at confirmation of purchase. Subscription automatically renews unless it is canceled at least 24 hours before the end of the current period. Your account will be charged for renewal within 24 hours prior to the end of the current period. You can manage and cancel your subscriptions by going to your account settings on the App Store after purchase.

Terms of Use (EULA): https://www.apple.com/legal/internet-services/itunes/dev/stdeula/
Privacy Policy: https://ozzzik.github.io/WaterReminderApp/privacy-policy.html
```

### Step 2: Update Privacy Policy Field

Go to **App Store Connect → Your App → App Privacy → Privacy Policy URL**

Enter:
```
https://ozzzik.github.io/WaterReminderApp/privacy-policy.html
```

### Step 3: Verify EULA Setting

Go to **App Store Connect → Your App → App Information → License Agreement**

Make sure it's set to:
- ✅ **"Standard Apple End User License Agreement (EULA)"**

Do NOT use a custom EULA unless you have specific legal requirements.

---

## ✅ CHECKLIST - BEFORE RESUBMITTING

### App Binary (Already Fixed ✅)
- ✅ Title of subscription displayed: "Premium Monthly", "Premium Yearly"
- ✅ Length of subscription: "1 month", "1 year"
- ✅ Price of subscription: "$0.99/month", "$9.99/year"
- ✅ Functional Privacy Policy link in app
- ✅ Functional Terms of Use (EULA) link in app

### App Store Connect Metadata (YOU MUST DO THIS)
- ⬜ Privacy Policy URL in Privacy Policy field
- ⬜ EULA link in App Description
- ⬜ Subscription details in App Description
- ⬜ Standard Apple EULA selected (not custom)

---

## 🎯 WHY APPLE'S STANDARD EULA?

Apple's Standard EULA is perfect for most apps because:

1. **✅ Legal Protection**: Written by Apple's lawyers, covers all common scenarios
2. **✅ Automatic Updates**: Apple keeps it current with laws and regulations
3. **✅ Multi-Language**: Automatically translated to all App Store languages
4. **✅ User Trust**: Users are familiar with Apple's standard terms
5. **✅ Less Maintenance**: You don't need to hire lawyers or update terms

The standard EULA is available at:
**https://www.apple.com/legal/internet-services/itunes/dev/stdeula/**

---

## 🔗 OFFICIAL APPLE RESOURCES

- [Apple Developer Program License Agreement - Schedule 2](https://developer.apple.com/programs/apple-developer-program-license-agreement/#S2)
- [App Store Review Guidelines 3.1.2](https://developer.apple.com/app-store/review/guidelines/#business)
- [Subscriptions Best Practices](https://developer.apple.com/app-store/subscriptions/)
- [Standard Apple EULA](https://www.apple.com/legal/internet-services/itunes/dev/stdeula/)

---

## 🚀 READY TO RESUBMIT!

Once you've completed the App Store Connect changes above:

1. ✅ **Build and Archive** your updated app (with EULA links)
2. ✅ **Upload to App Store Connect**
3. ✅ **Update App Description** with subscription details and EULA link
4. ✅ **Verify Privacy Policy URL** is set correctly
5. ✅ **Submit for Review**

Your app should now pass Apple's 3.1.2 Subscription requirements! 🎉

---

## ❓ TROUBLESHOOTING

**Q: Do I need to host my own EULA?**  
A: No! Use Apple's standard EULA link: `https://www.apple.com/legal/internet-services/itunes/dev/stdeula/`

**Q: What if I want a custom EULA?**  
A: You'd need to create a custom legal document, host it online, and add it to App Store Connect. Most apps don't need this.

**Q: Do I need both Privacy Policy AND EULA?**  
A: Yes! For subscription apps, Apple requires both functional links in:
- Your app's subscription screens
- Your App Store Connect metadata

**Q: Can I use a different EULA link?**  
A: If you're using Apple's standard EULA, always link to Apple's official page. This ensures users see the correct, up-to-date terms.

---

**Last Updated:** October 11, 2025  
**App Version:** 1.4















