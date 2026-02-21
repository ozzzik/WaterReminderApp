# 💧 Water Reminder - iOS App

A beautifully designed iOS app that helps you maintain proper hydration throughout the day with smart recurring notifications and intuitive water tracking.

![Water Reminder App](https://img.shields.io/badge/iOS-17.0+-blue.svg)
![Swift](https://img.shields.io/badge/Swift-5.0-orange.svg)
![Xcode](https://img.shields.io/badge/Xcode-15.0+-green.svg)
![License](https://img.shields.io/badge/License-MIT-yellow.svg)

## ✨ Features

### 🎯 **Smart Hydration Tracking**
- **Visual Progress Circle**: Beautiful animated circular progress indicator
- **Customizable Goals**: Set your personal daily water intake target
- **Quick Add Buttons**: One-tap water intake recording (½ cup, 1 cup, 2 cups)
- **Real-time Progress**: Instantly see your daily hydration status

### 🔔 **Intelligent Reminder System**
- **Recurring Daily Notifications**: Automatically scheduled reminders that continue every day
- **Customizable Intervals**: Set reminder frequency from every 15 minutes to every few hours
- **Active Hours**: Configure start and end times for reminders (e.g., 8 AM - 8 PM)
- **Smart Scheduling**: Notifications automatically adjust to your preferred schedule
- **Background Processing**: Works even when the app is closed

### 📱 **Modern User Experience**
- **Clean, Intuitive Interface**: Beautiful gradient backgrounds and smooth animations
- **Progress Visualization**: Engaging circular progress indicator with color-coded feedback
- **Quick Actions**: Easy-to-use buttons for recording water intake
- **Responsive Design**: Optimized for all iPhone screen sizes

### ⚙️ **Personalization Options**
- **Custom Water Goals**: Adjust daily targets based on personal needs
- **Flexible Scheduling**: Set preferred reminder times and intervals
- **Notification Preferences**: Choose when and how often to be reminded
- **Persistent Settings**: Preferences automatically saved and restored

## 🚀 Getting Started

### Prerequisites
- iOS 17.0 or later
- Xcode 15.0 or later
- Swift 5.0+

### Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/yourusername/WaterReminderApp.git
   cd WaterReminderApp
   ```

2. **Open in Xcode**
   ```bash
   open WaterReminderApp.xcodeproj
   ```

3. **Build and Run**
   - Select your target device or simulator
   - Press `Cmd + R` to build and run

### Building for Distribution

#### Development Build
```bash
./build_development.sh
```

#### App Store Build
```bash
./build_for_appstore.sh
```

## 🏗️ Project Structure

```
WaterReminderApp/
├── Sources/                          # Main app source code
│   ├── WaterReminderAppApp.swift    # App entry point
│   ├── ContentView.swift            # Main UI view
│   ├── WaterReminderManager.swift   # Core business logic
│   ├── NotificationManager.swift    # Notification handling
│   ├── SettingsView.swift           # Settings interface
│   └── Assets.xcassets/            # App icons and resources
├── AppStore_Images/                 # App Store screenshots and previews
├── build_development.sh             # Development build script
├── build_for_appstore.sh           # App Store build script
├── project.yml                      # XcodeGen project configuration
└── README.md                       # This file
```

## 🔧 Configuration

### Notification Permissions
The app requires notification permissions to send hydration reminders. Users will be prompted to grant permissions on first launch.

### Customization
- **Water Goals**: Adjust daily intake targets in Settings
- **Reminder Intervals**: Set custom notification frequencies
- **Active Hours**: Configure when reminders should be active

## 📱 Requirements

- **iOS Version**: 17.0+
- **Device Support**: iPhone (all screen sizes)
- **Permissions**: Notifications, Background App Refresh
- **Storage**: Minimal (under 10MB)

## 🎨 Design Features

- **Modern UI**: Clean, minimalist design with smooth animations
- **Accessibility**: Full VoiceOver support and accessibility features
- **Dark Mode**: Automatic dark/light mode support
- **Responsive**: Optimized for all iPhone screen sizes and orientations

## 🚀 Key Benefits

1. **Automated Reminders**: No manual rescheduling needed
2. **Beautiful Interface**: Engaging and intuitive user experience
3. **Smart Scheduling**: Adapts to your lifestyle and preferences
4. **Health Focus**: Promotes healthy hydration habits
5. **Privacy First**: No data collection or tracking

## 🤝 Contributing

We welcome contributions! Please feel free to submit issues and pull requests.

### Development Setup
1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 📞 Support

- **GitHub Issues**: [Report bugs or request features](https://github.com/ozzzik/WaterReminderApp/issues)
- **Email Support**: [rickhamp85@gmail.com](mailto:rickhamp85@gmail.com)
- **Documentation**: [Full documentation](https://github.com/ozzzik/WaterReminderApp/wiki)

## 🙏 Acknowledgments

- Built with SwiftUI and modern iOS development practices
- Icons and design elements created with care for user experience
- Special thanks to the iOS development community

---

**Stay hydrated, stay healthy! 💧✨**

Made with ❤️ for iOS users who care about their health and wellness.
