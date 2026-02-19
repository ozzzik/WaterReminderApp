# In-App Purchase Submission Guide

## Problem
Your app was rejected because the in-app purchase products (Premium Yearly/Monthly subscriptions) have not been submitted for review in App Store Connect.

## Solution Overview
You need to:
1. Create the subscription products in App Store Connect
2. Submit them for review with required screenshots
3. Upload a new binary

## Step-by-Step Instructions

### Step 1: Access App Store Connect
1. Go to [App Store Connect](https://appstoreconnect.apple.com)
2. Sign in with your Apple Developer account
3. Select your Water Reminder App

### Step 2: Create Subscription Products

#### 2.1 Navigate to In-App Purchases
1. In your app's dashboard, click on **"Features"** tab
2. Click on **"In-App Purchases"**
3. Click the **"+"** button to create a new in-app purchase

#### 2.2 Create Premium Monthly Subscription
1. Select **"Auto-Renewable Subscriptions"**
2. Fill in the details:
   - **Reference Name**: `Premium Monthly`
   - **Product ID**: `com.whio.waterreminder.monthly.v3`
   - **Subscription Group**: Create new group called "Premium Features"
   - **Subscription Duration**: 1 Month
   - **Price**: $0.99 (or your preferred price)
   - **Localization**: 
     - **Display Name**: "Premium Monthly"
     - **Description**: "Monthly premium subscription with unlimited access to all features"

#### 2.3 Create Premium Yearly Subscription
1. Create another auto-renewable subscription
2. Fill in the details:
   - **Reference Name**: `Premium Yearly`
   - **Product ID**: `com.whio.waterreminder.yearly.v3`
   - **Subscription Group**: "Premium Features" (same group as monthly)
   - **Subscription Duration**: 1 Year
   - **Price**: $5.99 (or your preferred price)
   - **Localization**:
     - **Display Name**: "Premium Yearly"
     - **Description**: "Annual premium subscription with unlimited access to all features. Save 50% compared to monthly subscription."

### Step 3: Set Up Introductory Offers (Optional but Recommended)
1. For each subscription, click **"Set Up Introductory Offer"**
2. Choose **"Free Trial"**
3. Set duration to **"1 Week"** (7 days)
4. This matches your app's "Try Premium Free for 7 Days" messaging

### Step 4: Create Required Screenshots

#### 4.1 App Review Screenshots
You **MUST** provide screenshots showing the in-app purchase flow. Create these screenshots:

1. **Paywall Screen**: Screenshot of your PaywallView showing subscription options
2. **Subscription Selection**: Screenshot of SubscriptionView showing monthly/yearly options
3. **Purchase Confirmation**: Screenshot showing the purchase confirmation dialog

#### 4.2 Screenshot Requirements
- **Resolution**: Use your app's actual resolution
- **Content**: Must show the actual subscription products being offered
- **Quality**: Clear, high-resolution images
- **Format**: PNG or JPEG

### Step 5: Submit In-App Purchases for Review

#### 5.1 Add Screenshots
1. For each subscription product, go to the **"App Review Information"** section
2. Upload the required screenshots showing:
   - The subscription being offered in your app
   - The purchase flow
   - Any relevant UI elements

#### 5.2 Submit for Review
1. Make sure both subscription products are in **"Ready to Submit"** status
2. Click **"Submit for Review"** for each product
3. Wait for Apple's review (usually 24-48 hours)

### Step 6: Upload New Binary

#### 6.1 Prepare New Build
1. Increment your app version (e.g., from 1.4 to 1.4.1 or higher)
2. Build and archive your app in Xcode
3. Upload to App Store Connect

#### 6.2 Submit App for Review
1. In App Store Connect, go to your app version
2. Add the new build
3. Submit for review

## Important Notes

### Product IDs Must Match
Ensure your product IDs in App Store Connect exactly match those in your code:
- `com.whio.waterreminder.monthly.v3`
- `com.whio.waterreminder.yearly.v3`

### Subscription Group
Both subscriptions should be in the same subscription group ("Premium Features") so users can switch between monthly and yearly.

### Pricing Strategy
- Monthly: $0.99-$1.99
- Yearly: $5.99-$9.99 (should be significantly cheaper than 12 months of monthly)

### Testing
Before submitting:
1. Test in sandbox environment
2. Verify product IDs match
3. Test purchase flow
4. Test restore purchases

## Common Issues and Solutions

### Issue: "Product not found"
- **Solution**: Ensure product IDs match exactly between code and App Store Connect

### Issue: "Subscription group mismatch"
- **Solution**: Both subscriptions must be in the same group

### Issue: "Missing screenshots"
- **Solution**: Apple requires screenshots showing the actual purchase flow

### Issue: "Subscription not available"
- **Solution**: Ensure subscriptions are submitted for review and approved

## Timeline
- **Creating products**: 5-10 minutes
- **Apple review of in-app purchases**: 24-48 hours
- **App review with new binary**: 24-48 hours
- **Total time**: 2-4 days

## Next Steps After Approval
1. Test the complete purchase flow
2. Monitor subscription metrics in App Store Connect
3. Set up App Store Server Notifications (optional but recommended)
4. Consider implementing subscription management features

## Support Resources
- [Apple's In-App Purchase Guide](https://developer.apple.com/help/app-store-connect/configure-in-app-purchase-settings/overview-for-configuring-in-app-purchases/)
- [StoreKit Documentation](https://developer.apple.com/documentation/storekit)
- [App Store Connect Help](https://developer.apple.com/help/app-store-connect/)

---

**Remember**: The key issue is that your in-app purchases exist in your code but haven't been created and submitted in App Store Connect. Follow this guide to resolve the rejection.





