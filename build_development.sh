#!/bin/bash

# 🚰 Development Build Script for Water Reminder App
# This script builds the app for development and testing

echo "🚰 Building Water Reminder App for Development..."

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Check if Xcode is installed
if ! command -v xcodebuild &> /dev/null; then
    echo -e "${RED}❌ Xcode not found. Please install Xcode first.${NC}"
    exit 1
fi

# Check if project exists
if [ ! -f "WaterReminderApp.xcodeproj/project.pbxproj" ]; then
    echo -e "${RED}❌ Xcode project not found. Please run 'xcodegen generate' first.${NC}"
    exit 1
fi

echo -e "${BLUE}📱 Project found: WaterReminderApp.xcodeproj${NC}"

# Clean previous builds
echo -e "${YELLOW}🧹 Cleaning previous builds...${NC}"
xcodebuild clean -project WaterReminderApp.xcodeproj -scheme WaterReminderApp -configuration Debug

if [ $? -ne 0 ]; then
    echo -e "${RED}❌ Clean failed${NC}"
    exit 1
fi

echo -e "${GREEN}✅ Clean successful${NC}"

# Build for simulator (Debug configuration)
echo -e "${YELLOW}🔨 Building for iOS Simulator (Debug configuration)...${NC}"
xcodebuild build -project WaterReminderApp.xcodeproj -scheme WaterReminderApp -configuration Debug -destination 'platform=iOS Simulator,name=iPhone 16'

if [ $? -ne 0 ]; then
    echo -e "${RED}❌ Build failed${NC}"
    exit 1
fi

echo -e "${GREEN}✅ Build successful!${NC}"
echo -e "${BLUE}📱 App is ready for testing in iOS Simulator${NC}"
echo -e ""
echo -e "${YELLOW}💡 To run on device:${NC}"
echo -e "   1. Open Xcode: open WaterReminderApp.xcodeproj"
echo -e "   2. Connect your iPhone"
echo -e "   3. Select your device in the device dropdown"
echo -e "   4. Configure code signing in Signing & Capabilities"
echo -e "   5. Build and Run (⌘+R)"
echo -e ""
echo -e "${YELLOW}💡 For App Store submission:${NC}"
echo -e "   1. Use Xcode Product → Archive"
echo -e "   2. Follow the distribution process"
echo -e "   3. Upload to App Store Connect"


