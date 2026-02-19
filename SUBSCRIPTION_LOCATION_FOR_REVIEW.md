# Premium Yearly Subscription Location in Binary

## Product Information

**Product ID**: `com.whio.waterreminder.yearly.v4`

**Display Name**: "Premium Yearly"

## Where to Find the Premium Yearly Subscription in the Binary

### 1. Product ID Definition
**File**: `Sources/SubscriptionManager.swift`  
**Lines**: 24-27

The subscription product ID is hardcoded in the `productIds` set:

```swift
private let productIds: Set<String> = [
    "com.whio.waterreminder.monthly.v4",
    "com.whio.waterreminder.yearly.v4"  // Premium Yearly subscription
]
```

### 2. Product Loading
**File**: `Sources/SubscriptionManager.swift`  
**Lines**: 76-93

The app loads the Premium Yearly subscription product from the App Store using StoreKit2:

```swift
func loadProducts() async {
    do {
        print("📦 Loading products...")
        let loadedProducts = try await Product.products(for: productIds)
        // Products are loaded including "com.whio.waterreminder.yearly.v4"
        products = loadedProducts.sorted { $0.price < $1.price }
    }
}
```

### 3. Yearly Product Accessor
**File**: `Sources/SubscriptionManager.swift`  
**Lines**: 361-364

The yearly product can be accessed via the computed property:

```swift
/// Get yearly product
var yearlyProduct: Product? {
    products.first { $0.id.contains("yearly") }
}
```

### 4. User Interface Display
**File**: `Sources/SubscriptionView.swift`  
**Lines**: 68-78

The Premium Yearly subscription is displayed as a selectable option in the subscription screen:

```swift
// Yearly Option (Recommended)
if let yearlyProduct = subscriptionManager.yearlyProduct {
    SubscriptionOptionView(
        product: yearlyProduct,
        isRecommended: true,  // Marked as "BEST VALUE"
        isSelected: selectedProduct?.id == yearlyProduct.id,
        savingsText: subscriptionManager.yearlySavings
    ) {
        selectedProduct = yearlyProduct
    }
}
```

### 5. Auto-Selection
**File**: `Sources/SubscriptionView.swift`  
**Lines**: 160-163

The Premium Yearly subscription is automatically selected when the subscription screen loads:

```swift
// Auto-select yearly product if available
if let yearlyProduct = subscriptionManager.yearlyProduct {
    print("✅ Auto-selected yearly product: \(yearlyProduct.id)")
    selectedProduct = yearlyProduct
}
```

### 6. Purchase Functionality
**File**: `Sources/SubscriptionView.swift`  
**Lines**: 179-218

Users can purchase the Premium Yearly subscription by selecting it and tapping the purchase button:

```swift
private func purchaseSubscription() {
    guard let product = selectedProduct else { return }
    // The selectedProduct can be the yearly product (com.whio.waterreminder.yearly.v4)
    Task {
        try await subscriptionManager.purchase(product)
    }
}
```

### 7. Purchase Implementation
**File**: `Sources/SubscriptionManager.swift`  
**Lines**: 98-174

The actual purchase is handled using StoreKit2:

```swift
func purchase(_ product: Product) async throws {
    // This method handles purchases for both monthly and yearly subscriptions
    // The product parameter can be the yearly product (com.whio.waterreminder.yearly.v4)
    let result = try await product.purchase()
    // Process transaction...
}
```

### 8. Subscription Status Check
**File**: `Sources/SubscriptionManager.swift`  
**Lines**: 206-264

The app checks for active Premium Yearly subscriptions:

```swift
func updateSubscriptionStatus() async {
    // Checks Transaction.currentEntitlements for active subscriptions
    // Including "com.whio.waterreminder.yearly.v4"
    for await result in Transaction.currentEntitlements {
        if productIds.contains(transaction.productID) {
            // Found active subscription (monthly or yearly)
        }
    }
}
```

### 9. StoreKit Configuration
**File**: `Configuration.storekit`  
**Lines**: 105-133

The subscription is configured in the StoreKit configuration file:

```json
{
  "productID" : "com.whio.waterreminder.yearly.v4",
  "localizations" : [
    {
      "displayName" : "Premium Yearly",
      "description" : "Annual premium subscription with unlimited access to all features. Save 50% compared to monthly subscription.",
      "locale" : "en_US"
    }
  ],
  "referenceName" : "Premium Yearly",
  "recurringSubscriptionPeriod" : "P1Y"
}
```

## How to Access in the App

1. **From Paywall Screen**: Tap "Continue with Premium" button → Opens `SubscriptionView`
2. **From Settings**: Navigate to Settings → Tap "Manage Subscription" → Opens `SubscriptionView`
3. **Direct Access**: The `SubscriptionView` displays both subscription options, with Premium Yearly selected by default

## Visual Identification

In the `SubscriptionView`:
- Premium Yearly appears as the **top option** with a "BEST VALUE" badge
- Shows the yearly price (e.g., "$5.99/year")
- Displays savings percentage (e.g., "Save 50%")
- Has a checkmark when selected (selected by default)
- Can be tapped to select before purchase

## Summary

The Premium Yearly subscription (`com.whio.waterreminder.yearly.v4`) is:
- ✅ Defined in code: `SubscriptionManager.swift` line 26
- ✅ Loaded from App Store: `SubscriptionManager.swift` line 80
- ✅ Displayed in UI: `SubscriptionView.swift` lines 69-78
- ✅ Auto-selected by default: `SubscriptionView.swift` lines 161-163
- ✅ Purchaseable: `SubscriptionView.swift` lines 179-218
- ✅ Tracked for status: `SubscriptionManager.swift` lines 206-264
- ✅ Configured in StoreKit: `Configuration.storekit` lines 105-133

The subscription is fully functional and accessible to users through the app's subscription purchase flow.


