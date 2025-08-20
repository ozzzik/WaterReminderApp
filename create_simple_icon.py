from PIL import Image, ImageDraw
import os

def create_simple_water_icon(size):
    # Create a simple blue background
    img = Image.new('RGB', (size, size), (0, 122, 255))
    draw = ImageDraw.Draw(img)
    
    # Add a white border
    border_width = max(1, size // 20)
    draw.rectangle([0, 0, size-1, size-1], outline=(255, 255, 255), width=border_width)
    
    # Add a simple white circle in the center (water drop)
    center = size // 2
    drop_size = size // 3
    draw.ellipse([center-drop_size, center-drop_size, center+drop_size, center+drop_size], fill=(255, 255, 255))
    
    return img

def main():
    print("🎨 Creating simple water app icons...")
    
    # Create the main asset catalog directory
    os.makedirs("Sources/Assets.xcassets/AppIcon.appiconset", exist_ok=True)
    
    # Create icons for all required sizes
    icon_sizes = {
        "Icon-20.png": 20,
        "Icon-20@2x.png": 40,
        "Icon-20@3x.png": 60,
        "Icon-29.png": 29,
        "Icon-29@2x.png": 58,
        "Icon-29@3x.png": 87,
        "Icon-40.png": 40,
        "Icon-40@2x.png": 80,
        "Icon-40@3x.png": 120,
        "Icon-60.png": 60,
        "Icon-60@2x.png": 120,
        "Icon-60@3x.png": 180,
        "Icon-76.png": 76,
        "Icon-76@2x.png": 152,
        "Icon-83.5@2x.png": 167,
        "Icon-1024.png": 1024
    }
    
    for filename, size in icon_sizes.items():
        icon = create_simple_water_icon(size)
        output_path = f"Sources/Assets.xcassets/AppIcon.appiconset/{filename}"
        icon.save(output_path, "PNG")
        file_size = os.path.getsize(output_path)
        print(f"✅ Created {filename} ({size}x{size}) - Size: {file_size} bytes")
    
    print("🎉 Simple app icons created!")

if __name__ == "__main__":
    main()
