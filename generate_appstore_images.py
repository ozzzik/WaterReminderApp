#!/usr/bin/env python3
"""
App Store Image Generator for Water Reminder App
Generates screenshots and app previews in required dimensions
"""

import os
from PIL import Image, ImageDraw, ImageFont
import textwrap

# App Store required dimensions
REQUIRED_DIMENSIONS = [
    (1242, 2688),   # iPhone 11 Pro Max, 12 Pro Max, 13 Pro Max, 14 Pro Max
    (2688, 1242),   # iPhone 11 Pro Max, 12 Pro Max, 13 Pro Max, 14 Pro Max (landscape)
    (1284, 2778),   # iPhone 12 Pro Max, 13 Pro Max, 14 Pro Max, 15 Pro Max
    (2778, 1284),   # iPhone 12 Pro Max, 13 Pro Max, 14 Pro Max, 15 Pro Max (landscape)
]

# App Store image types
IMAGE_TYPES = {
    'screenshots': 10,      # 10 screenshots required
    'app_previews': 3       # 3 app previews required
}

def create_gradient_background(width, height, color1=(135, 206, 250), color2=(70, 130, 180)):
    """Create a beautiful gradient background"""
    img = Image.new('RGB', (width, height))
    draw = ImageDraw.Draw(img)
    
    for y in range(height):
        r = int(color1[0] + (color2[0] - color1[0]) * y / height)
        g = int(color1[1] + (color2[1] - color1[1]) * y / height)
        b = int(color1[2] + (color2[2] - color1[2]) * y / height)
        draw.line([(0, y), (width, y)], fill=(r, g, b))
    
    return img

def create_water_drop_icon(size, color=(70, 130, 180)):
    """Create a water drop icon"""
    img = Image.new('RGBA', (size, size), (0, 0, 0, 0))
    draw = ImageDraw.Draw(img)
    
    # Water drop shape
    center_x, center_y = size // 2, size // 2
    drop_width = size // 3
    drop_height = size // 2
    
    # Draw water drop
    points = [
        (center_x, center_y - drop_height // 2),
        (center_x - drop_width // 2, center_y + drop_height // 2),
        (center_x + drop_width // 2, center_y + drop_height // 2)
    ]
    draw.polygon(points, fill=color)
    
    # Add highlight
    highlight_size = size // 6
    draw.ellipse([
        center_x - highlight_size // 2,
        center_y - drop_height // 3,
        center_x + highlight_size // 2,
        center_y - drop_height // 3 + highlight_size
    ], fill=(255, 255, 255, 128))
    
    return img

def create_screenshot(width, height, title, subtitle, features, screenshot_num):
    """Create a screenshot-style image"""
    img = create_gradient_background(width, height)
    draw = ImageDraw.Draw(img)
    
    # Try to load a font, fall back to default if not available
    try:
        title_font = ImageFont.truetype("/System/Library/Fonts/Helvetica.ttc", size=width//20)
        subtitle_font = ImageFont.truetype("/System/Library/Fonts/Helvetica.ttc", size=width//30)
        feature_font = ImageFont.truetype("/System/Library/Fonts/Helvetica.ttc", size=width//35)
    except:
        title_font = ImageFont.load_default()
        subtitle_font = ImageFont.load_default()
        feature_font = ImageFont.load_default()
    
    # Add water drop icon
    icon_size = width // 8
    water_icon = create_water_drop_icon(icon_size)
    icon_x = (width - icon_size) // 2
    icon_y = height // 6
    img.paste(water_icon, (icon_x, icon_y), water_icon)
    
    # Add title
    title_bbox = draw.textbbox((0, 0), title, font=title_font)
    title_width = title_bbox[2] - title_bbox[0]
    title_x = (width - title_width) // 2
    title_y = icon_y + icon_size + height // 20
    draw.text((title_x, title_y), title, fill=(255, 255, 255), font=title_font)
    
    # Add subtitle
    subtitle_bbox = draw.textbbox((0, 0), subtitle, font=subtitle_font)
    subtitle_width = subtitle_bbox[2] - subtitle_bbox[0]
    subtitle_x = (width - subtitle_width) // 2
    subtitle_y = title_y + height // 15
    draw.text((subtitle_x, subtitle_y), subtitle, fill=(200, 200, 200), font=subtitle_font)
    
    # Add features
    feature_y = subtitle_y + height // 12
    for i, feature in enumerate(features):
        feature_bbox = draw.textbbox((0, 0), feature, font=feature_font)
        feature_width = feature_bbox[2] - feature_bbox[0]
        feature_x = (width - feature_width) // 2
        draw.text((feature_x, feature_y), feature, fill=(255, 255, 255), font=feature_font)
        feature_y += height // 20
    
    # Add screenshot number
    draw.text((width - 100, height - 50), f"#{screenshot_num}", fill=(255, 255, 255), font=subtitle_font)
    
    return img

def create_app_preview(width, height, title, description, preview_num):
    """Create an app preview image"""
    img = create_gradient_background(width, height, (70, 130, 180), (135, 206, 250))
    draw = ImageDraw.Draw(img)
    
    try:
        title_font = ImageFont.truetype("/System/Library/Fonts/Helvetica.ttc", size=width//15)
        desc_font = ImageFont.truetype("/System/Library/Fonts/Helvetica.ttc", size=width//25)
    except:
        title_font = ImageFont.load_default()
        desc_font = ImageFont.load_default()
    
    # Add water drop icon
    icon_size = width // 6
    water_icon = create_water_drop_icon(icon_size, (255, 255, 255))
    icon_x = (width - icon_size) // 2
    icon_y = height // 4
    img.paste(water_icon, (icon_x, icon_y), water_icon)
    
    # Add title
    title_bbox = draw.textbbox((0, 0), title, font=title_font)
    title_width = title_bbox[2] - title_bbox[0]
    title_x = (width - title_width) // 2
    title_y = icon_y + icon_size + height // 15
    draw.text((title_x, title_y), title, fill=(255, 255, 255), font=title_font)
    
    # Add description
    desc_bbox = draw.textbbox((0, 0), description, font=desc_font)
    desc_width = desc_bbox[2] - desc_bbox[0]
    desc_x = (width - desc_width) // 2
    desc_y = title_y + height // 10
    draw.text((desc_x, desc_y), description, fill=(200, 200, 200), font=desc_font)
    
    # Add preview number
    draw.text((width - 120, height - 60), f"Preview {preview_num}", fill=(255, 255, 255), font=desc_font)
    
    return img

def main():
    """Generate all required App Store images"""
    # Create output directory
    output_dir = "AppStore_Images"
    os.makedirs(output_dir, exist_ok=True)
    
    # Screenshot content
    screenshots = [
        ("Stay Hydrated", "Track your daily water intake", ["• Beautiful progress circle", "• Quick add buttons", "• Daily goals"]),
        ("Smart Reminders", "Never forget to drink water", ["• Custom intervals", "• Active hours", "• Push notifications"]),
        ("Progress Tracking", "Monitor your hydration", ["• Visual progress", "• Daily statistics", "• Goal achievement"]),
        ("Custom Settings", "Personalize your experience", ["• Adjustable goals", "• Flexible schedules", "• User preferences"]),
        ("Beautiful UI", "Modern design", ["• Clean interface", "• Smooth animations", "• Intuitive navigation"]),
        ("Health Focus", "Prioritize wellness", ["• Hydration tracking", "• Health reminders", "• Wellness goals"]),
        ("Daily Goals", "Set achievable targets", ["• Customizable amounts", "• Progress tracking", "• Success celebration"]),
        ("Smart Notifications", "Stay on track", ["• Timely reminders", "• Custom schedules", "• Background processing"]),
        ("Data Insights", "Track your progress", ["• Daily statistics", "• Progress history", "• Achievement tracking"]),
        ("Easy to Use", "Simple and intuitive", ["• One-tap adding", "• Quick settings", "• User-friendly design"])
    ]
    
    # App preview content
    app_previews = [
        ("Stay Hydrated", "Track your daily water intake with beautiful visual progress and smart reminders"),
        ("Smart Reminders", "Get notified when it's time to drink water with customizable intervals and schedules"),
        ("Health Focus", "Prioritize your wellness with easy water tracking and progress monitoring")
    ]
    
    print("🚰 Generating App Store Images for Water Reminder App...")
    
    # Generate screenshots for each dimension
    for width, height in REQUIRED_DIMENSIONS:
        dimension_dir = f"{output_dir}/{width}x{height}"
        os.makedirs(dimension_dir, exist_ok=True)
        
        print(f"\n📱 Generating {width}x{height} images...")
        
        # Generate screenshots
        for i, (title, subtitle, features) in enumerate(screenshots, 1):
            img = create_screenshot(width, height, title, subtitle, features, i)
            filename = f"{dimension_dir}/screenshot_{i:02d}_{width}x{height}.png"
            img.save(filename, "PNG")
            print(f"  ✅ Screenshot {i}: {filename}")
        
        # Generate app previews
        for i, (title, description) in enumerate(app_previews, 1):
            img = create_app_preview(width, height, title, description, i)
            filename = f"{dimension_dir}/preview_{i:02d}_{width}x{height}.png"
            img.save(filename, "PNG")
            print(f"  ✅ Preview {i}: {filename}")
    
    print(f"\n🎉 All App Store images generated successfully!")
    print(f"📁 Output directory: {output_dir}")
    print(f"📊 Total images: {len(REQUIRED_DIMENSIONS) * (IMAGE_TYPES['screenshots'] + IMAGE_TYPES['app_previews'])}")
    
    # Create a summary file
    summary_file = f"{output_dir}/README.md"
    with open(summary_file, 'w') as f:
        f.write("# App Store Images for Water Reminder App\n\n")
        f.write("## Generated Images\n\n")
        for width, height in REQUIRED_DIMENSIONS:
            f.write(f"### {width}x{height} Dimension\n")
            f.write(f"- **Screenshots**: 10 images\n")
            f.write(f"- **App Previews**: 3 images\n")
            f.write(f"- **Total**: 13 images\n\n")
        f.write("## Usage\n\n")
        f.write("1. Upload screenshots to App Store Connect\n")
        f.write("2. Upload app previews to App Store Connect\n")
        f.write("3. Ensure all required dimensions are covered\n\n")
        f.write("## Requirements Met\n\n")
        f.write("- ✅ 10 screenshots per dimension\n")
        f.write("- ✅ 3 app previews per dimension\n")
        f.write("- ✅ All required dimensions covered\n")
        f.write("- ✅ Professional design and branding\n")
    
    print(f"📝 Summary file created: {summary_file}")

if __name__ == "__main__":
    main()


