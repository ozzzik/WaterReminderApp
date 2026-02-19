# Sandbox Test Account Setup Guide

## Overview
Sandbox Test Accounts allow you to test in-app purchases and subscriptions without using real money. This guide walks you through creating and managing sandbox testers in App Store Connect.

## Prerequisites
- Apple Developer Account (paid membership required)
- App Store Connect access
- iOS device for testing
- Xcode installed

## Step-by-Step Setup

### Step 1: Access App Store Connect
1. **Open your web browser** and go to [appstoreconnect.apple.com](https://appstoreconnect.apple.com)
2. **Sign in** with your Apple Developer Account credentials
3. **Wait for the dashboard to load**

### Step 2: Navigate to Sandbox Testers
1. **Look for the "Users and Access" section** in the left sidebar
2. **Click on "Users and Access"** to expand the menu
3. **Click on "Sandbox Testers"** from the submenu
4. **You should see the Sandbox Testers page** with existing testers (if any)

### Step 3: Create New Sandbox Tester
1. **Click the "+" button** (plus icon) in the top-right corner
2. **Select "Sandbox Tester"** from the dropdown menu
3. **The "Create Sandbox Tester" form will appear**

### Step 4: Fill in Tester Information
Fill out the form with the following information:

#### Required Fields:
- **First Name**: `Test` (or any name you prefer)
- **Last Name**: `User` (or any name you prefer)
- **Email**: Use a real, unique email address
  - **Important**: This must be a real email address that you can access
  - **Example**: `testuser.waterreminder+1@gmail.com`
  - **Tip**: Use `+1`, `+2`, etc. to create multiple test accounts with the same base email
- **Password**: Create a strong password (8+ characters)
  - **Requirements**: At least 8 characters, mix of letters and numbers
  - **Example**: `TestPass123!`
- **Confirm Password**: Re-enter the same password
- **Country/Region**: Select your country/region from the dropdown
  - **Important**: This affects pricing and currency display

#### Optional Fields:
- **Storefront**: Usually auto-selected based on country
- **Notes**: Add any notes for your reference (e.g., "Testing Water Reminder App")

### Step 5: Review and Create
1. **Double-check all information** is correct
2. **Verify the email format** is valid
3. **Ensure password meets requirements**
4. **Click "Invite"** to create the sandbox tester

### Step 6: Verify Creation
1. **You should see a success message** confirming the tester was created
2. **The new tester should appear** in the Sandbox Testers list
3. **Note the email address** - you'll need this for device testing

## Creating Multiple Test Accounts

### For Different Testing Scenarios:
Create multiple sandbox testers for comprehensive testing:

#### Account 1: Basic Testing
- **Email**: `testuser.waterreminder+1@gmail.com`
- **Purpose**: General subscription testing

#### Account 2: Trial Testing
- **Email**: `trial.waterreminder+1@gmail.com`
- **Purpose**: Testing trial flows and expiration

#### Account 3: Cancellation Testing
- **Email**: `cancel.waterreminder+1@gmail.com`
- **Purpose**: Testing subscription cancellation and grace periods

#### Account 4: Edge Cases
- **Email**: `edge.waterreminder+1@gmail.com`
- **Purpose**: Testing error scenarios and edge cases

## Managing Sandbox Testers

### Viewing Testers
1. **Go to "Users and Access"** → **"Sandbox Testers"**
2. **See all created testers** in the list
3. **View tester details** by clicking on a tester

### Editing Testers
1. **Click on a tester** from the list
2. **Click "Edit"** button
3. **Modify information** as needed
4. **Click "Save"** to update

### Deleting Testers
1. **Select a tester** from the list
2. **Click "Delete"** button
3. **Confirm deletion** when prompted

## Important Notes

### Email Requirements
- **Must be unique** across all your sandbox testers
- **Must be a real email address** that you can access
- **Must follow valid email format** (user@domain.com)
- **Use +1, +2, etc.** to create multiple accounts with same base email

### Password Requirements
- **Minimum 8 characters**
- **Mix of letters and numbers**
- **Special characters allowed** but not required
- **Case sensitive**

### Country/Region Impact
- **Affects currency display** in your app
- **Affects pricing** shown to users
- **Should match your target market** for accurate testing

### Testing Limitations
- **Sandbox purchases are free** - no real money charged
- **Testers can only test** your app's in-app purchases
- **Cannot test other apps** with sandbox account
- **Account expires** after 90 days of inactivity

## Troubleshooting

### Common Issues

#### "Email already exists"
- **Solution**: Use a different email address or add +1, +2, etc.

#### "Invalid email format"
- **Solution**: Ensure email follows proper format and is a real email address

#### "Password too weak"
- **Solution**: Use at least 8 characters with letters and numbers

#### "Cannot create tester"
- **Solution**: Check your Apple Developer Account status and permissions

### Best Practices

1. **Use descriptive email addresses** for easy identification
2. **Keep a record** of all test account credentials
3. **Create accounts for different scenarios** (trial, subscription, cancellation)
4. **Test with different countries** if targeting multiple regions
5. **Regularly clean up** unused test accounts

## Next Steps

After creating sandbox testers:

1. **Set up test device** (sign out of personal Apple ID)
2. **Sign in with sandbox account** on device
3. **Configure Xcode scheme** with StoreKit configuration
4. **Build and test** your app on device
5. **Follow testing scenarios** in the main testing guide

## Security Considerations

- **Never use real personal information** in sandbox testers
- **Use unique passwords** for each test account
- **Don't share sandbox credentials** publicly
- **Regularly rotate** test account passwords
- **Delete unused accounts** to maintain security

---

**Note**: Sandbox testers are only for testing purposes and cannot be used for real purchases. Always use your personal Apple ID for actual app purchases and subscriptions.
