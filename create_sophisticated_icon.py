from PIL import Image, ImageDraw
import os
import math

def create_sophisticated_water_icon(size):
    # Create a sophisticated gradient background
    img = Image.new('RGB', (size, size), (0, 0, 0))
    draw = ImageDraw.Draw(img)
    
    # Create a modern radial gradient from dark blue to light blue
    center = size // 2
    max_radius = size // 2
    
    for y in range(size):
        for x in range(size):
            # Calculate distance from center
            dx = x - center
            dy = y - center
            distance = math.sqrt(dx*dx + dy*dy)
            
            # Normalize distance (0 to 1)
            normalized_distance = min(distance / max_radius, 1.0)
            
            # Create gradient colors
            if normalized_distance < 0.3:
                # Dark blue center
                r = int(0 + normalized_distance * 50)
                g = int(30 + normalized_distance * 70)
                b = int(120 + normalized_distance * 80)
            elif normalized_distance < 0.7:
                # Medium blue
                r = int(50 + (normalized_distance - 0.3) * 100)
                g = int(100 + (normalized_distance - 0.3) * 100)
                b = int(200 + (normalized_distance - 0.3) * 50)
            else:
                # Light blue edges
                r = int(150 + (normalized_distance - 0.7) * 100)
                g = int(200 + (normalized_distance - 0.7) * 55)
                b = int(250 + (normalized_distance - 0.7) * 5)
            
            color = (max(0, min(255, r)), max(0, min(255, g)), max(0, min(255, b)))
            img.putpixel((x, y), color)
    
    # Add a subtle glow effect in the center
    glow_radius = size // 4
    for i in range(glow_radius, 0, -1):
        alpha = int(30 * (i / glow_radius))
        color = (100, 200, 255, alpha)
        draw.ellipse([center-i, center-i, center+i, center+i], fill=color)
    
    # Create a sophisticated water drop with glass effect
    drop_center = (center, center)
    drop_size = size // 3
    
    # Drop shadow (subtle)
    shadow_offset = size // 25
    shadow_blur = size // 30
    for i in range(shadow_blur):
        alpha = int(40 * (1 - i / shadow_blur))
        shadow_size = drop_size + i
        draw.ellipse([
            drop_center[0] - shadow_size + shadow_offset,
            drop_center[1] - shadow_size + shadow_offset,
            drop_center[0] + shadow_size + shadow_offset,
            drop_center[1] + shadow_size + shadow_offset
        ], fill=(0, 0, 0, alpha))
    
    # Main drop (glass effect with gradient)
    for i in range(drop_size):
        # Create gradient within the drop
        alpha = int(200 - (i / drop_size) * 100)
        current_size = drop_size - i
        
        # Gradient from white to light blue
        if i < drop_size * 0.3:
            color = (255, 255, 255, alpha)
        elif i < drop_size * 0.7:
            color = (220, 240, 255, alpha)
        else:
            color = (180, 220, 255, alpha)
        
        draw.ellipse([
            drop_center[0] - current_size,
            drop_center[1] - current_size,
            drop_center[0] + current_size,
            drop_center[1] + current_size
        ], fill=color)
    
    # Add sophisticated highlights
    highlight_size = drop_size // 2
    highlight_offset = drop_size // 4
    
    # Main highlight (bright white)
    draw.ellipse([
        drop_center[0] - highlight_size + highlight_offset,
        drop_center[1] - highlight_size - highlight_offset,
        drop_center[0] + highlight_size + highlight_offset,
        drop_center[1] + highlight_size - highlight_offset
    ], fill=(255, 255, 255, 180))
    
    # Secondary highlight (smaller, more subtle)
    small_highlight = highlight_size // 2
    draw.ellipse([
        drop_center[0] - small_highlight + highlight_offset//2,
        drop_center[1] - small_highlight - highlight_offset//2,
        drop_center[0] + small_highlight + highlight_offset//2,
        drop_center[1] + small_highlight - highlight_offset//2
    ], fill=(255, 255, 255, 220))
    
    # Add water ripple effect (subtle)
    ripple_count = 2
    for i in range(ripple_count):
        ripple_radius = (size // 3) + (i * size // 6)
        ripple_alpha = int(80 - (i * 30))
        ripple_width = max(1, size // 80)
        
        # Draw ripple rings with gradient
        for j in range(ripple_width):
            current_radius = ripple_radius + j
            alpha = int(ripple_alpha * (1 - j / ripple_width))
            color = (255, 255, 255, alpha)
            draw.ellipse([
                center - current_radius,
                center - current_radius,
                center + current_radius,
                center + current_radius
            ], outline=color, width=1)
    
    # Add floating water particles (sophisticated)
    particle_count = 6
    for i in range(particle_count):
        angle = (i / particle_count) * 2 * math.pi
        distance = size // 2.5
        x = center + int(math.cos(angle) * distance)
        y = center + int(math.sin(angle) * distance)
        
        # Vary particle sizes
        particle_size = size // 50 + (i % 2) * (size // 100)
        
        # Create gradient particles
        for j in range(particle_size):
            alpha = int(150 * (1 - j / particle_size))
            color = (255, 255, 255, alpha)
            draw.ellipse([
                x - j, y - j,
                x + j, y + j
            ], fill=color)
    
    # No border - full blue background to edges
    return img

def main():
    print("🎨 Creating FULL-BLEED sophisticated water app icon...")
    
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
        icon = create_sophisticated_water_icon(size)
        output_path = f"Sources/Assets.xcassets/AppIcon.appiconset/{filename}"
        icon.save(output_path, "PNG")
        file_size = os.path.getsize(output_path)
        print(f"🔥 Created {filename} ({size}x{size}) - Size: {file_size} bytes")
    
    print("🚀 FULL-BLEED sophisticated app icons created! Blue background to the edges!")

if __name__ == "__main__":
    main()
