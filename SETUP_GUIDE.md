# Water Reminder App - Setup Guide

## 🚰 Project Overview

This is a complete iOS and Apple Watch app that helps users stay hydrated by providing customizable water intake reminders. The app features a beautiful SwiftUI interface, local notifications, and seamless cross-device synchronization.

## 📁 Project Structure

```
WaterReminderApp/
├── 📱 iPhone App Files
│   ├── WaterReminderAppApp.swift      # Main app entry point
│   ├── ContentView.swift              # Main iPhone interface
│   ├── SettingsView.swift             # Settings and configuration
│   ├── WaterReminderManager.swift     # Core business logic
│   ├── NotificationManager.swift      # Notification handling
│   ├── Info.plist                     # App configuration
│   └── Assets.xcassets/               # App icons and assets
├── ⌚ Apple Watch App Files
│   ├── WaterReminderApp Watch App.swift  # Watch app entry point
│   ├── WatchContentView.swift         # Watch interface
│   ├── WatchSettingsView.swift        # Watch settings
│   ├── Info.plist                     # Watch app configuration
│   └── Assets.xcassets/               # Watch app icons
├── 📋 Configuration Files
│   ├── project.yml                    # XcodeGen project configuration
│   ├── build.sh                       # Automated build script
│   └── README.md                      # Detailed documentation
└── 📖 Documentation
    ├── demo.md                        # App demo and features
    └── SETUP_GUIDE.md                 # This file
```

## 🛠️ Setup Instructions

### Prerequisites
- macOS with Xcode 15.0 or later
- iOS 17.0+ deployment target
- watchOS 10.0+ deployment target
- Apple Developer Account (for device testing)

### Quick Start (Recommended)

1. **Run the Build Script**
   ```bash
   cd /Users/ohardoon/WaterReminderApp
   ./build.sh
   ```

2. **If XcodeGen is not installed**
   ```bash
   # Install Homebrew first (if not installed)
   /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
   
   # Install XcodeGen
   brew install xcodegen
   
   # Run build script again
   ./build.sh
   ```

### Manual Setup

If you prefer to create the project manually:

1. **Open Xcode**
2. **Create New Project**
   - Choose "App" under iOS
   - Product Name: "WaterReminderApp"
   - Bundle Identifier: "com.yourcompany.WaterReminderApp"
   - Language: Swift
   - Interface: SwiftUI
   - Life Cycle: SwiftUI App

3. **Add Apple Watch Target**
   - File → New → Target
   - Choose "Watch App" under watchOS
   - Product Name: "WaterReminderApp Watch App"
   - Bundle Identifier: "com.yourcompany.WaterReminderApp.watch"

4. **Add Source Files**
   - Copy all Swift files to the appropriate targets
   - Ensure shared files (WaterReminderManager, NotificationManager) are added to both targets

## 🎯 Key Features

### iPhone App
- **Water Intake Tracking**: Visual progress circle with real-time updates
- **Quick Add Buttons**: One-tap water logging (½ cup, 1 cup, 2 cups)
- **Customizable Reminders**: Set intervals from 30 minutes to custom hours
- **Time Range Settings**: Configure active hours for reminders
- **Daily Goal Setting**: Customizable daily water intake goal
- **Progress Persistence**: Automatically saves and loads user preferences

### Apple Watch App
- **Simplified Interface**: Optimized for small screen with essential features
- **Quick Water Logging**: Easy one-tap water intake recording
- **Progress Display**: Compact progress circle showing daily goal
- **Haptic Feedback**: Tactile confirmation when logging water intake
- **Sync with iPhone**: Shared data between iPhone and Apple Watch

## 🔧 Configuration

### Bundle Identifiers
Update the bundle identifiers in the project settings:
- iPhone App: `com.yourcompany.WaterReminderApp`
- Apple Watch App: `com.yourcompany.WaterReminderApp.watch`

### App Icons
Add your app icons to the respective `Assets.xcassets` folders:
- iPhone: Various sizes from 20x20 to 1024x1024
- Apple Watch: 20x20, 24x24, 29.5x29.5, 40x40, 1024x1024

### Development Team
Select your development team in project settings for device testing.

## 🚀 Running the App

### Simulator Testing
1. Select iPhone simulator as target
2. Press Cmd+R to build and run
3. For Apple Watch testing, use the Apple Watch simulator

### Device Testing
1. Connect your iPhone and Apple Watch
2. Select your device as target
3. Ensure both devices are signed in with the same Apple ID
4. Build and run on iPhone first, then Apple Watch

## 📱 App Usage

### First-Time Setup
1. Launch the app and grant notification permissions
2. Set your daily water intake goal (default: 8 cups)
3. Enable reminders and choose an interval (default: 1 hour)
4. Configure active hours (default: 8 AM to 8 PM)

### Daily Usage
1. View your progress in the circular indicator
2. Tap quick add buttons to log water intake
3. Check settings for customization options
4. Monitor reminder notifications

### Apple Watch Usage
1. Open the Apple Watch app
2. View compact progress display
3. Tap water logging buttons for haptic feedback
4. Access settings for quick adjustments

## 🔍 Troubleshooting

### Common Issues

1. **Notifications Not Working**
   - Ensure notification permissions are granted
   - Check that reminders are enabled in settings
   - Verify the device is not in Do Not Disturb mode

2. **Data Not Syncing Between Devices**
   - Ensure both iPhone and Apple Watch apps are installed
   - Check that the same Apple ID is used on both devices
   - Restart both devices if needed

3. **App Crashes on Launch**
   - Clean build folder (Cmd+Shift+K)
   - Delete app from device and reinstall
   - Check for any missing asset files

4. **Build Errors**
   - Ensure all Swift files are added to the correct targets
   - Check that shared files are included in both iPhone and Apple Watch targets
   - Verify bundle identifiers are unique and properly formatted

### Getting Help
- Check the `README.md` for detailed documentation
- Review `demo.md` for feature demonstrations
- Ensure all prerequisites are met
- Try the automated build script first

## 🎉 Success!

Once the app is running, you'll have a fully functional water reminder app that:
- Tracks daily water intake with beautiful visual feedback
- Provides customizable reminders based on your schedule
- Works seamlessly across iPhone and Apple Watch
- Persists your settings and progress automatically
- Offers an intuitive and modern user experience

Enjoy staying hydrated! 💧

