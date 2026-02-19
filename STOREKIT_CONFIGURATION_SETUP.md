# StoreKit Configuration Setup in Xcode

## Overview
StoreKit Configuration allows you to test in-app purchases and subscriptions locally in Xcode without needing App Store Connect or sandbox accounts. This guide walks you through setting it up step by step.

## What is StoreKit Configuration?
- **Local testing environment** for in-app purchases
- **No App Store Connect required** for basic testing
- **Works in simulator** and on device
- **Uses `.storekit` configuration files** to define products
- **Perfect for development** and initial testing

## Prerequisites
- Xcode 12.0 or later
- iOS 14.0 or later
- Your app project open in Xcode

## Step-by-Step Setup

### Step 1: Create StoreKit Configuration File

#### Option A: Create New Configuration
1. **Open your Xcode project**
2. **Right-click on your project** in the navigator
3. **Select "New File..."**
4. **Choose "iOS" tab** → **"Resource"** → **"StoreKit Configuration File"**
5. **Name it** `Products.storekit` (or any name you prefer)
6. **Click "Create"**

#### Option B: Use Existing Configuration
1. **Look for existing `.storekit` file** in your project
2. **If found, skip to Step 2**
3. **If not found, follow Option A above**

### Step 2: Configure Products in StoreKit File

1. **Select the `.storekit` file** in Xcode navigator
2. **You'll see the StoreKit Configuration editor**

#### Add Monthly Subscription
1. **Click the "+" button** in the products section
2. **Select "Auto-Renewable Subscription"**
3. **Fill in the details:**
   - **Reference Name**: `Monthly Premium`
   - **Product ID**: `com.whio.waterreminder.monthly`
   - **Subscription Duration**: `1 Month`
   - **Price**: `$1.99` (or your preferred price)
   - **Localization**: Add your preferred language

#### Add Yearly Subscription
1. **Click the "+" button** again
2. **Select "Auto-Renewable Subscription"**
3. **Fill in the details:**
   - **Reference Name**: `Yearly Premium`
   - **Product ID**: `com.whio.waterreminder.yearly`
   - **Subscription Duration**: `1 Year`
   - **Price**: `$9.99` (or your preferred price)
   - **Localization**: Add your preferred language

#### Add Non-Consumable Product (Optional)
1. **Click the "+" button**
2. **Select "Non-Consumable"**
3. **Fill in the details:**
   - **Reference Name**: `Premium Upgrade`
   - **Product ID**: `com.whio.waterreminder.premium`
   - **Price**: `$4.99`

### Step 3: Configure Subscription Groups

1. **In the StoreKit editor, find "Subscription Groups"**
2. **Click the "+" button** to add a new group
3. **Set the group name**: `Premium Subscriptions`
4. **Add both monthly and yearly products** to this group
5. **Set the subscription level**: `1` (for both products)

### Step 4: Set Up Xcode Scheme

1. **Go to Product menu** → **Scheme** → **Edit Scheme...**
2. **Select "Run"** from the left sidebar
3. **Click on "Options" tab**
4. **Find "StoreKit Configuration"** section
5. **Select your `.storekit` file** from the dropdown
6. **Click "Close"** to save

### Step 5: Verify Configuration

1. **Build and run** your app (⌘+R)
2. **Check the console** for StoreKit messages
3. **Test in-app purchases** using your debug controls
4. **Verify products load** correctly

## Detailed Configuration Examples

### Monthly Subscription Configuration
```json
{
  "identifier": "com.whio.waterreminder.monthly",
  "referenceName": "Monthly Premium",
  "productId": "com.whio.waterreminder.monthly",
  "type": "RecurringSubscription",
  "subscriptionPeriod": "P1M",
  "subscriptionPeriodUnit": "month",
  "price": 1.99,
  "currencyCode": "USD"
}
```

### Yearly Subscription Configuration
```json
{
  "identifier": "com.whio.waterreminder.yearly",
  "referenceName": "Yearly Premium", 
  "productId": "com.whio.waterreminder.yearly",
  "type": "RecurringSubscription",
  "subscriptionPeriod": "P1Y",
  "subscriptionPeriodUnit": "year",
  "price": 9.99,
  "currencyCode": "USD"
}
```

## Testing with StoreKit Configuration

### What You Can Test
- ✅ **Product loading** and display
- ✅ **Purchase flows** and user experience
- ✅ **Subscription states** and lifecycle
- ✅ **Receipt validation** and parsing
- ✅ **Error handling** and edge cases
- ✅ **UI/UX flows** and interactions

### What You Cannot Test
- ❌ **Real payment processing** (no money charged)
- ❌ **App Store Connect integration** (local only)
- ❌ **Real subscription renewals** (simulated)
- ❌ **Real cancellation flows** (simulated)
- ❌ **Production receipt validation** (test receipts)

## Troubleshooting

### Common Issues

#### "No Products Available"
**Solution:**
1. **Check product IDs** match exactly in code and configuration
2. **Verify StoreKit file** is selected in scheme
3. **Ensure products are properly configured** in the file
4. **Check console** for StoreKit error messages

#### "StoreKit Configuration Not Found"
**Solution:**
1. **Verify `.storekit` file** is in your project
2. **Check scheme configuration** has the file selected
3. **Clean and rebuild** project (⌘+Shift+K, then ⌘+B)
4. **Restart Xcode** if issues persist

#### "Products Load But Purchase Fails"
**Solution:**
1. **Check StoreKit configuration** is properly set up
2. **Verify product types** match your code expectations
3. **Check subscription groups** are configured correctly
4. **Review console logs** for specific error messages

### Debug Tips

#### Enable StoreKit Logging
1. **Go to Product** → **Scheme** → **Edit Scheme**
2. **Select "Run"** → **"Arguments"** tab
3. **Add environment variable**: `-StoreKitTestingEnabled YES`
4. **Click "Close"** and run again

#### Check Console Output
Look for these messages:
- `StoreKit: Products loaded successfully`
- `StoreKit: Purchase initiated`
- `StoreKit: Purchase completed`
- `StoreKit: Error: [specific error]`

## Advanced Configuration

### Testing Different Scenarios

#### Test Subscription Renewal
1. **In StoreKit editor**, find your subscription
2. **Set "Renewal Behavior"** to "Renew"
3. **Set "Renewal Interval"** to test different periods

#### Test Subscription Cancellation
1. **Set "Renewal Behavior"** to "Cancel"
2. **Set "Cancellation Date"** to test grace period
3. **Test your app's cancellation handling**

#### Test Subscription Expiration
1. **Set "Renewal Behavior"** to "Expire"
2. **Set "Expiration Date"** to test expired state
3. **Verify your app handles expiration correctly**

### Multiple Configurations

#### Create Different Test Scenarios
1. **Duplicate your `.storekit` file**
2. **Rename to** `Products-Trial.storekit`
3. **Modify products** for different test scenarios
4. **Switch between configurations** in scheme settings

## Best Practices

### Configuration Management
- **Keep configurations simple** for initial testing
- **Use descriptive names** for products and groups
- **Test with realistic prices** and durations
- **Document different scenarios** for team members

### Development Workflow
1. **Start with StoreKit Configuration** for rapid development
2. **Test all purchase flows** and edge cases
3. **Move to sandbox testing** when features are stable
4. **Use production testing** for final validation

### Code Integration
```swift
// Your code should work with both configurations
func loadProducts() {
    Task {
        do {
            let products = try await Product.products(for: productIDs)
            // Handle products
        } catch {
            print("Failed to load products: \(error)")
        }
    }
}
```

## Next Steps

After setting up StoreKit Configuration:

1. **Test your debug controls** work with the configuration
2. **Verify product loading** and display
3. **Test purchase flows** and user experience
4. **Move to sandbox testing** when ready
5. **Set up App Store Connect** for production

## Summary

StoreKit Configuration is perfect for:
- **Initial development** and testing
- **UI/UX validation** and user flows
- **Debugging purchase logic** and state management
- **Testing without App Store Connect** setup

It's the first step in a comprehensive testing strategy that leads to sandbox and production testing! 🚀

















