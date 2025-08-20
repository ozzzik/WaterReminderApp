#!/bin/bash

echo "🔧 Xcode Setup Script"
echo "====================="

# Check if Xcode is installed
if [ -d "/Applications/Xcode.app" ]; then
    echo "✅ Xcode found at /Applications/Xcode.app"
    
    # Set Xcode as the active developer directory
    echo "🔧 Setting Xcode as active developer directory..."
    sudo xcode-select --switch /Applications/Xcode.app/Contents/Developer
    
    # Accept Xcode license
    echo "📝 Accepting Xcode license..."
    sudo xcodebuild -license accept
    
    # Install additional components
    echo "📦 Installing additional components..."
    sudo xcodebuild -runFirstLaunch
    
    echo ""
    echo "🎉 Xcode setup complete!"
    echo ""
    echo "Next steps:"
    echo "1. Open Xcode: open /Applications/Xcode.app"
    echo "2. Open your project: open WaterReminderApp.xcodeproj"
    echo "3. Select your development team in project settings"
    echo "4. Build and run your app!"
    
else
    echo "❌ Xcode not found at /Applications/Xcode.app"
    echo ""
    echo "Please install Xcode first:"
    echo "1. Open App Store"
    echo "2. Search for 'Xcode'"
    echo "3. Click 'Get' or 'Install'"
    echo "4. Wait for download to complete (~12GB)"
    echo "5. Run this script again"
fi

