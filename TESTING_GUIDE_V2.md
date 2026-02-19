# 🧪 COMPLETE TESTING GUIDE - 3 Environments

## 🎯 **THREE TESTING ENVIRONMENTS**

Your app supports **3 completely separate testing environments**. Each has a specific purpose and different setup requirements.

---

## **📱 ENVIRONMENT 1: XCODE TESTING (StoreKit Configuration File)**

### **Purpose:**
- **Fast local development**
- **Unit testing**
- **UI testing**
- **No real Apple ID needed**
- **No internet required**

### **How It Works:**
- Uses `Configuration.storekit` file
- Simulates in-app purchases locally
- No real money involved
- Instant testing (no server delays)
- Can simulate renewals, cancellations, errors

### **Setup:**

1. **StoreKit Configuration File Already Set Up:**
   - File: `/Users/ohardoon/WaterReminderApp/Configuration.storekit`
   - Contains: `com.whio.waterreminder.monthly.v2` and `com.whio.waterreminder.yearly.v2`

2. **Configure Xcode Scheme:**
   ```
   1. Product → Scheme → Edit Scheme...
   2. Run (Debug) → Options tab
   3. StoreKit Configuration → Select "Configuration.storekit"
   4. Click Close
   ```

3. **Run in Simulator:**
   ```bash
   # From command line
   xcodebuild -project WaterReminderApp.xcodeproj \
     -scheme WaterReminderApp \
     -destination 'platform=iOS Simulator,name=iPhone 16' \
     build
   
   # Or use Xcode: Cmd + R
   ```

### **Testing:**
- ✅ Products load from StoreKit config
- ✅ Purchase flow works (simulated)
- ✅ Subscription status updates
- ✅ Restore purchases works
- ✅ **Debug Tools visible** (Developer Tools in Settings)

### **Debug Tools Access:**
1. Open app in Simulator
2. Settings → Scroll to bottom
3. "Developer Tools" section appears (**Xcode only!**)
4. Tap "Debug Subscription"
5. View detailed diagnostics, test actions

### **Pros:**
- ⚡ Instant testing
- 🔄 Unlimited purchases
- 🧪 Can test all scenarios
- 🚫 No Apple ID needed
- 💰 No real money

### **Cons:**
- ❌ Not testing real Apple servers
- ❌ Different from production behavior
- ❌ Can't test actual renewal timing

### **Use Cases:**
- Development and debugging
- Quick iteration
- UI/UX testing
- Feature development
- Unit tests

---

## **📱 ENVIRONMENT 2: SANDBOX TESTING (Real Device + Sandbox Account)**

### **Purpose:**
- **Test real Apple servers** (sandbox environment)
- **Verify server integration**
- **Test accelerated renewals**
- **Validate StoreKit2 implementation**

### **How It Works:**
- Uses real Apple servers (sandbox mode)
- Requires sandbox tester account
- Accelerated subscription timing:
  - **3 minutes = 1 month**
  - **5 minutes = 1 renewal**
  - **Max 6 renewals** then auto-expires
- No real money involved

### **Setup:**

#### **Step 1: Create Sandbox Tester Account**

1. **Go to App Store Connect:**
   https://appstoreconnect.apple.com

2. **Navigate to:**
   - Users and Access → Sandbox → Testers

3. **Create New Sandbox Tester:**
   ```
   Email: your.email+sandbox1@gmail.com
   Password: [Strong password]
   First Name: Test
   Last Name: User
   Date of Birth: [18+ years old]
   Country: United States
   ```

4. **Important:**
   - ✅ Email must be real (for verification)
   - ✅ Use `+` alias (e.g., `yourname+sandbox1@gmail.com`)
   - ✅ Never use this email for real Apple ID
   - ✅ Can create multiple sandbox accounts

#### **Step 2: Configure Products in App Store Connect**

1. **Go to:**
   - My Apps → Your App → Subscriptions

2. **Create Monthly Subscription:**
   ```
   Product ID: com.whio.waterreminder.monthly.v2
   Reference Name: Premium Monthly v2
   Duration: 1 Month
   Price: $0.99
   Subscription Group: Premium Subscriptions v2
   Status: Ready to Submit
   ```

3. **Create Yearly Subscription:**
   ```
   Product ID: com.whio.waterreminder.yearly.v2
   Reference Name: Premium Yearly v2
   Duration: 1 Year
   Price: $9.99
   Subscription Group: Premium Subscriptions v2
   Status: Ready to Submit
   ```

4. **Important:**
   - ✅ Both products in **same subscription group**
   - ✅ Mark as **"Ready to Submit"**
   - ✅ Set appropriate pricing
   - ✅ Add localized descriptions

#### **Step 3: Build to Device**

1. **Connect your iPad/iPhone**

2. **Configure Xcode Scheme (Important!):**
   ```
   1. Product → Scheme → Edit Scheme...
   2. Run (Debug) → Options tab
   3. StoreKit Configuration → Select "NONE" (don't use local file!)
   4. Click Close
   ```

3. **Build to Device:**
   ```
   1. Select your device in Xcode
   2. Press Cmd + R
   3. Wait for app to install
   ```

#### **Step 4: Sign In with Sandbox Account**

1. **DO NOT sign into Settings with sandbox account!**
2. **Open your app**
3. **Try to purchase a subscription**
4. **iOS will prompt for Apple ID**
5. **Enter sandbox account credentials**
6. **Complete purchase**

### **Testing:**
- ✅ Products load from App Store Connect (sandbox)
- ✅ Purchase flow uses real servers
- ✅ Accelerated renewals (3 min = 1 month)
- ✅ Subscription management works
- ✅ **No Debug Tools visible** (production behavior)

### **Important Notes:**
- ⚠️ **Sandbox subscriptions renew fast** (every 3-5 minutes)
- ⚠️ **Max 6 renewals** then auto-expires
- ⚠️ **Cannot see in iOS Settings → Subscriptions**
- ⚠️ **Can only manage through App Store app** (sometimes doesn't work)
- ⚠️ **Phantom subscriptions** can occur (Apple bug)

### **Pros:**
- ✅ Tests real Apple servers
- ✅ Validates StoreKit2 implementation
- ✅ Accelerated testing (fast renewals)
- 💰 No real money

### **Cons:**
- ❌ Requires sandbox account setup
- ❌ Phantom subscriptions (Apple bug)
- ❌ Can't see in Settings
- ❌ Harder to cancel subscriptions
- ❌ Not exactly like production

### **Use Cases:**
- Server integration testing
- Renewal testing
- Cancellation testing
- StoreKit2 validation
- Pre-TestFlight testing

---

## **📱 ENVIRONMENT 3: TESTFLIGHT (Beta Testing)**

### **Purpose:**
- **Final testing before App Store**
- **Test with real users**
- **Production-like experience**
- **Uses your real Apple ID**

### **How It Works:**
- App uploaded to App Store Connect
- Distributed via TestFlight
- Uses real Apple servers (sandbox mode automatically)
- Accelerated renewals (same as sandbox)
- Looks like production, acts like sandbox

### **Setup:**

#### **Step 1: Archive App**

```bash
cd /Users/ohardoon/WaterReminderApp

# Archive
xcodebuild archive \
  -project WaterReminderApp.xcodeproj \
  -scheme WaterReminderApp \
  -archivePath ./build/WaterReminderApp.xcarchive \
  -destination 'generic/platform=iOS'
```

#### **Step 2: Export for App Store**

```bash
# Export
xcodebuild -exportArchive \
  -archivePath ./build/WaterReminderApp.xcarchive \
  -exportOptionsPlist export_options.plist \
  -exportPath ./build/export
```

#### **Step 3: Upload to App Store Connect**

**Option A: Using Xcode (Recommended)**
```
1. Window → Organizer
2. Select your archive
3. Click "Distribute App"
4. Select "App Store Connect"
5. Click "Upload"
6. Wait for processing (~5-10 minutes)
```

**Option B: Using Command Line**
```bash
xcrun altool --upload-app \
  --type ios \
  --file ./build/export/WaterReminderApp.ipa \
  --username "your@email.com" \
  --password "app-specific-password"
```

#### **Step 4: Configure TestFlight**

1. **Go to App Store Connect:**
   https://appstoreconnect.apple.com

2. **My Apps → Your App → TestFlight**

3. **Wait for Processing** (5-10 minutes)

4. **Add External Testers:**
   - TestFlight → External Testing → Add Testers
   - Enter email addresses
   - Testers receive invite

5. **Install on Device:**
   - Testers install TestFlight app
   - Accept invite
   - Install your app

### **Testing:**
- ✅ Production-like UI (no debug tools)
- ✅ Real Apple servers (sandbox mode)
- ✅ Accelerated renewals (3 min = 1 month)
- ✅ Uses your real Apple ID
- ✅ **Hidden sandbox subscriptions** (TestFlight behavior)

### **Important Notes:**
- ⚠️ **Subscriptions use sandbox mode** (even with real Apple ID)
- ⚠️ **Subscriptions are HIDDEN** (not visible in Settings)
- ⚠️ **Can't cancel easily** (Apple's TestFlight behavior)
- ⚠️ **May need to clear purchase history** (App Store Connect)

### **Pros:**
- ✅ Production-like experience
- ✅ Real user testing
- ✅ Clean UI (no debug)
- ✅ Uses real Apple ID
- ✅ Easy distribution

### **Cons:**
- ❌ Subscriptions are hidden
- ❌ Harder to debug
- ❌ Upload/processing delays
- ❌ Requires App Store Connect
- ❌ Phantom subscriptions possible

### **Use Cases:**
- Final testing before launch
- Beta user testing
- Real-world validation
- Performance testing
- User feedback

---

## **🔄 COMPARISON TABLE**

| Feature | Xcode (StoreKit Config) | Sandbox (Device) | TestFlight (Beta) |
|---------|------------------------|------------------|-------------------|
| **Purpose** | Fast development | Server integration | Final testing |
| **Apple Servers** | ❌ Local simulation | ✅ Real (sandbox) | ✅ Real (sandbox) |
| **Apple ID** | ❌ Not needed | ✅ Sandbox account | ✅ Real Apple ID |
| **Setup Time** | ⚡ Instant | ⏱️ 10 minutes | ⏱️ 20 minutes |
| **Products** | StoreKit file | App Store Connect | App Store Connect |
| **Renewals** | ⚡ Instant | 🚀 3 min = 1 month | 🚀 3 min = 1 month |
| **Debug Tools** | ✅ Visible | ❌ Hidden | ❌ Hidden |
| **Real Money** | ❌ No | ❌ No | ❌ No |
| **Subscriptions Visible** | N/A | ❌ Hidden | ❌ Hidden |
| **Best For** | Development | Server testing | Beta testing |

---

## **🎯 TESTING WORKFLOW**

### **Recommended Order:**

1. **Xcode Testing (Hours 1-10)**
   - Develop features
   - Fix bugs
   - Test UI/UX
   - Iterate quickly

2. **Sandbox Testing (Day 11)**
   - Test server integration
   - Validate StoreKit2
   - Test renewals
   - Fix server issues

3. **TestFlight Testing (Day 12+)**
   - Beta user testing
   - Final validation
   - Real-world testing
   - Prepare for launch

---

## **🚨 TROUBLESHOOTING**

### **Problem: Products Don't Load in Xcode**
**Solution:**
1. Check `Configuration.storekit` has correct product IDs
2. Product → Scheme → Edit Scheme → Options
3. Verify StoreKit Configuration is selected
4. Clean build (Cmd + Shift + K)
5. Rebuild

### **Problem: Products Don't Load in Sandbox**
**Solution:**
1. Verify products created in App Store Connect
2. Products marked as "Ready to Submit"
3. Scheme does NOT have StoreKit Configuration selected
4. Wait 10 minutes after creating products
5. Try restoring purchases

### **Problem: Products Don't Load in TestFlight**
**Solution:**
1. Verify products approved in App Store Connect
2. Wait 10-15 minutes after upload
3. Delete app and reinstall from TestFlight
4. Check console logs for errors

### **Problem: Sandbox Subscription Won't Cancel**
**Solution:**
1. This is a known Apple bug (phantom subscriptions)
2. Go to: https://appstoreconnect.apple.com/access/testers
3. Sandbox → Your account → Clear Purchase History
4. Wait 10 minutes
5. Delete and reinstall app

### **Problem: TestFlight Subscription Is Hidden**
**Solution:**
1. This is expected TestFlight behavior
2. Subscriptions use sandbox mode (hidden from Settings)
3. Use "Clear Purchase History" in App Store Connect
4. Or create new sandbox tester account

---

## **📝 TESTING CHECKLIST**

### **Xcode Testing:**
- [ ] Products load from StoreKit config
- [ ] Purchase flow works
- [ ] Subscription status updates
- [ ] Restore purchases works
- [ ] Debug tools accessible
- [ ] UI looks correct
- [ ] All features work

### **Sandbox Testing:**
- [ ] Products load from App Store Connect
- [ ] Sandbox account works
- [ ] Purchase flow completes
- [ ] Accelerated renewals work
- [ ] Subscription can be managed
- [ ] Restore purchases works
- [ ] No debug tools visible

### **TestFlight Testing:**
- [ ] App uploads successfully
- [ ] Beta testers can install
- [ ] Products load correctly
- [ ] Purchase flow works
- [ ] No debug UI visible
- [ ] Production-like experience
- [ ] Performance is good

---

## **🎯 SUMMARY**

- **Xcode = Fast development** (StoreKit config, instant testing)
- **Sandbox = Server testing** (Real Apple servers, accelerated timing)
- **TestFlight = Final validation** (Beta users, production-like)

**Start with Xcode, move to Sandbox, finish with TestFlight!** 🚀















