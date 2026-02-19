# Required Screenshots for In-App Purchase Review

## Overview
Apple requires specific screenshots showing your in-app purchase flow for review. These screenshots must demonstrate that your subscription products are properly integrated into your app.

## Required Screenshots

### 1. Paywall Screen Screenshot
**Purpose**: Show the main subscription offer screen

**What to capture**:
- Your PaywallView showing "Try Premium Free for 7 Days"
- The "Continue with Premium" button
- Feature list (Unlimited Reminders, Progress Tracking, etc.)
- Pricing information ("Just $1/month")

**How to capture**:
1. Run your app in the simulator or on device
2. Navigate to the paywall screen
3. Take a screenshot (Cmd+Shift+4 on Mac, or device screenshot)
4. Save as PNG or JPEG

### 2. Subscription Selection Screen Screenshot
**Purpose**: Show the subscription options (Monthly/Yearly)

**What to capture**:
- Your SubscriptionView showing both subscription options
- Monthly subscription details
- Yearly subscription details
- Purchase buttons for each option

**How to capture**:
1. From PaywallView, tap "Continue with Premium"
2. This should open SubscriptionView
3. Take a screenshot showing both options
4. Save as PNG or JPEG

### 3. Purchase Confirmation Dialog Screenshot
**Purpose**: Show the actual purchase flow

**What to capture**:
- The native iOS purchase confirmation dialog
- "Confirm Purchase" dialog
- Subscription details in the dialog
- Price information

**How to capture**:
1. Tap on a subscription option
2. When the purchase dialog appears, take a screenshot
3. **Important**: Don't complete the purchase, just capture the dialog
4. Save as PNG or JPEG

## Screenshot Requirements

### Technical Specifications
- **Format**: PNG or JPEG
- **Resolution**: Use your app's native resolution
- **Quality**: High resolution, clear and readable
- **Size**: No specific size limit, but should be clear

### Content Requirements
- **Must show**: Actual subscription products being offered
- **Must show**: Your app's UI with the subscription flow
- **Must show**: Pricing information
- **Must show**: Purchase buttons/options

### What NOT to Include
- Don't show personal information
- Don't show actual payment details
- Don't complete real purchases (use sandbox if testing)

## How to Create Screenshots

### Method 1: iOS Simulator (Recommended)
1. Open your app in iOS Simulator
2. Navigate to the paywall screen
3. Use Cmd+Shift+4 to take screenshots
4. Save to Desktop

### Method 2: Physical Device
1. Run your app on a physical device
2. Navigate to the paywall screen
3. Take screenshots using device controls
4. Transfer to your computer

### Method 3: Xcode Screenshots
1. Run your app in Xcode
2. Use Xcode's screenshot tools
3. Save the screenshots

## Screenshot Checklist

Before submitting, ensure you have:

- [ ] **Paywall Screen**: Shows main subscription offer
- [ ] **Subscription Options**: Shows monthly/yearly choices
- [ ] **Purchase Dialog**: Shows native iOS purchase confirmation
- [ ] **Clear Text**: All text is readable and clear
- [ ] **Proper Resolution**: Screenshots are high quality
- [ ] **Complete Flow**: Shows the entire purchase journey

## Uploading Screenshots in App Store Connect

### Step 1: Access In-App Purchase
1. Go to App Store Connect
2. Select your app
3. Go to Features > In-App Purchases
4. Select your subscription product

### Step 2: Add Screenshots
1. Scroll to "App Review Information" section
2. Click "Add Screenshot"
3. Upload your screenshots
4. Add descriptive captions if needed

### Step 3: Submit for Review
1. Ensure all required information is filled
2. Click "Submit for Review"
3. Wait for Apple's review

## Common Screenshot Issues

### Issue: "Screenshots don't show purchase flow"
**Solution**: Make sure screenshots show the actual subscription options and purchase buttons

### Issue: "Screenshots are blurry"
**Solution**: Use high-resolution screenshots from simulator or device

### Issue: "Missing purchase dialog"
**Solution**: You need to show the native iOS purchase confirmation dialog

### Issue: "Screenshots don't match app"
**Solution**: Ensure screenshots are from your actual app, not mockups

## Testing Your Screenshots

Before submitting:
1. **Verify Content**: Do screenshots show your actual subscription products?
2. **Check Quality**: Are screenshots clear and readable?
3. **Test Flow**: Does the flow make sense from screenshot to screenshot?
4. **Match App**: Do screenshots match your actual app UI?

## Alternative: Video Recording

If screenshots are difficult, you can also provide a video:
1. Record a screen recording of the purchase flow
2. Upload as MP4 file
3. Keep it short (30-60 seconds)
4. Show the complete flow from paywall to purchase dialog

## Timeline

- **Creating screenshots**: 10-15 minutes
- **Uploading to App Store Connect**: 5 minutes
- **Apple review**: 24-48 hours

## Pro Tips

1. **Use Simulator**: Easier to take consistent screenshots
2. **Test First**: Make sure your purchase flow works before taking screenshots
3. **Multiple Angles**: Take screenshots from different parts of the flow
4. **High Quality**: Use the highest resolution possible
5. **Be Complete**: Show the entire user journey

---

**Remember**: These screenshots are mandatory for in-app purchase review. Without them, Apple cannot approve your subscriptions.





