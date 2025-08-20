#!/bin/bash

# 🚀 App Store Build Script for Water Reminder App
# This script prepares the app for App Store submission

echo "🚰 Building Water Reminder App for App Store Submission..."

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
xcodebuild clean -project WaterReminderApp.xcodeproj -scheme WaterReminderApp -configuration Release

if [ $? -ne 0 ]; then
    echo -e "${RED}❌ Clean failed${NC}"
    exit 1
fi

echo -e "${GREEN}✅ Clean successful${NC}"

# Build for device (Release configuration)
echo -e "${YELLOW}🔨 Building for device (Release configuration)...${NC}"
echo -e "${BLUE}💡 Note: This requires proper code signing setup for App Store distribution${NC}"

# Try to build for device
xcodebuild build -project WaterReminderApp.xcodeproj -scheme WaterReminderApp -configuration Release -destination generic/platform=iOS

if [ $? -ne 0 ]; then
    echo -e "${RED}❌ Build failed${NC}"
    echo -e "${YELLOW}💡 This is expected for App Store builds. You need to:${NC}"
    echo -e "   1. Open Xcode: open WaterReminderApp.xcodeproj"
    echo -e "   2. Configure code signing in Signing & Capabilities"
    echo -e "   3. Select your Apple Developer Team"
    echo -e "   4. Use Product → Archive instead"
    echo -e ""
    echo -e "${BLUE}🔄 Trying development build instead...${NC}"
    
    # Try development build
    xcodebuild build -project WaterReminderApp.xcodeproj -scheme WaterReminderApp -configuration Debug -destination generic/platform=iOS
    
    if [ $? -ne 0 ]; then
        echo -e "${RED}❌ Development build also failed${NC}"
        exit 1
    fi
    
    echo -e "${GREEN}✅ Development build successful${NC}"
    echo -e "${YELLOW}⚠️  For App Store submission, use Xcode Product → Archive${NC}"
    exit 0
fi

echo -e "${GREEN}✅ Build successful${NC}"

# Archive the app
echo -e "${YELLOW}📦 Archiving app for App Store...${NC}"
xcodebuild archive -project WaterReminderApp.xcodeproj -scheme WaterReminderApp -configuration Release -archivePath build/WaterReminderApp.xcarchive -destination generic/platform=iOS

if [ $? -ne 0 ]; then
    echo -e "${RED}❌ Archive failed${NC}"
    exit 1
fi

echo -e "${GREEN}✅ Archive successful${NC}"

# Check archive
if [ -d "build/WaterReminderApp.xcarchive" ]; then
    echo -e "${GREEN}🎉 App successfully archived!${NC}"
    echo -e "${BLUE}📁 Archive location: build/WaterReminderApp.xcarchive${NC}"
    echo -e "${BLUE}📱 Next steps:${NC}"
    echo -e "   1. Open Xcode"
    echo -e "   2. Window → Organizer"
    echo -e "   3. Select your archive"
    echo -e "   4. Click 'Distribute App'"
    echo -e "   5. Choose 'App Store Connect'"
    echo -e "   6. Follow the upload process"
else
    echo -e "${RED}❌ Archive not found${NC}"
    exit 1
fi

echo -e "${GREEN}🚀 Ready for App Store submission!${NC}"
