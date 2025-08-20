#!/bin/bash

# Water Reminder App Build Script
# This script helps set up and build the Water Reminder app

set -e

echo "🚰 Water Reminder App Build Script"
echo "=================================="

# Check if we're in the right directory
if [ ! -f "project.yml" ]; then
    echo "❌ Error: project.yml not found. Please run this script from the WaterReminderApp directory."
    exit 1
fi

# Check for XcodeGen
if command -v xcodegen &> /dev/null; then
    echo "✅ XcodeGen found"
    
    echo "📦 Generating Xcode project..."
    xcodegen generate
    
    if [ -d "WaterReminderApp.xcodeproj" ]; then
        echo "✅ Xcode project generated successfully!"
        
        echo "🔧 Opening project in Xcode..."
        open WaterReminderApp.xcodeproj
        
        echo ""
        echo "🎉 Setup complete! The project should now be open in Xcode."
        echo ""
        echo "Next steps:"
        echo "1. Select your development team in project settings"
        echo "2. Update bundle identifiers if needed"
        echo "3. Add app icons to Assets.xcassets"
        echo "4. Build and run on your device or simulator"
        echo ""
        echo "For Apple Watch testing, you'll need:"
        echo "- A physical Apple Watch paired with your iPhone"
        echo "- Or use the Apple Watch simulator in Xcode"
    else
        echo "❌ Failed to generate Xcode project"
        exit 1
    fi
else
    echo "⚠️  XcodeGen not found"
    echo ""
    echo "To install XcodeGen:"
    echo "1. Install Homebrew: https://brew.sh"
    echo "2. Run: brew install xcodegen"
    echo ""
    echo "Or download from: https://github.com/yonaskolb/XcodeGen/releases"
    echo ""
    echo "Alternatively, you can create the project manually in Xcode:"
    echo "1. Open Xcode"
    echo "2. Create New Project → iOS App"
    echo "3. Add Watch App target"
    echo "4. Copy all Swift files to appropriate targets"
    exit 1
fi
