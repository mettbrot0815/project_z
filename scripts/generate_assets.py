#!/usr/bin/env python3
"""
Generate placeholder assets for Z (1996) recreation
Creates minimal valid PNG and OGG files for testing
"""

import os
import struct
import zlib
import math

# Colors
RED = (255, 0, 0)
BLUE = (0, 0, 255)
GREEN = (0, 255, 0)
YELLOW = (255, 255, 0)
BLACK = (0, 0, 0)
WHITE = (255, 255, 255)
GRAY = (128, 128, 128)

def create_png(filename, width, height, pixels):
    """Create a minimal PNG file"""
    def chunk(data, chunk_type):
        data = bytes(data)
        length = struct.pack('>I', len(data))
        crc = struct.pack('>I', zlib.crc32(chunk_type + data) & 0xffffffff)
        return length + chunk_type + data + crc
    
    # PNG signature
    signature = b'\x89PNG\r\n\x1a\n'
    
    # IHDR chunk
    ihdr_data = struct.pack('>IIBBBBB', width, height, 8, 2, 0, 0, 0)
    ihdr = chunk(ihdr_data, b'IHDR')
    
    # IDAT chunk (image data)
    raw_data = b''
    for y in range(height):
        raw_data += b'\x00'  # filter type: none
        for x in range(width):
            raw_data += bytes(pixels[x + y * width])
    
    compressed = zlib.compress(raw_data, 9)
    idat = chunk(compressed, b'IDAT')
    
    # IEND chunk
    iend = chunk(b'', b'IEND')
    
    with open(filename, 'wb') as f:
        f.write(signature + ihdr + idat + iend)
    
    print(f"  Created: {filename} ({width}x{height})")

def create_ogg(filename, data):
    """Create a minimal OGG Vorbis file"""
    # OGG header
    header = struct.pack('<B', 0x4f)  # 'O'
    header += struct.pack('>I', len(data))  # page length
    header += struct.pack('>I', 0)  # page sequence number
    header += struct.pack('>I', 0)  # granule position
    header += b'\x00' * 4  # checksums
    
    # Vorbis comment
    comment = b'Vorbis Comment\nZ (1996) Recreation\nPlaceholder'
    header += struct.pack('<B', 0x63)  # 'c'
    header += struct.pack('>I', len(comment))
    header += comment
    
    # Packet header
    packet_header = struct.pack('>I', len(data))
    packet_header += b'\x80'  # packet type: vorbis
    
    with open(filename, 'wb') as f:
        f.write(header + packet_header + data)
    
    print(f"  Created: {filename}")

def create_placeholder_audio(filename, duration=0.5, frequency=440):
    """Create a simple sine wave audio file"""
    # Sample rate and duration
    sample_rate = 44100
    num_samples = int(sample_rate * duration)
    
    # Generate sine wave
    data = bytearray()
    for i in range(num_samples):
        # Simple sine wave with some noise
        value = int(8000 * math.sin(2 * math.pi * frequency * i / sample_rate))
        data.extend(struct.pack('<h', value))
    
    # Add some silence at the end
    data.extend(b'\x00' * (num_samples * 2))
    
    # Create OGG file
    create_ogg(filename, bytes(data))

def create_placeholder_sprite(filename, size=64, color=RED):
    """Create a simple colored sprite"""
    # Generate simple pattern
    pixels = []
    for y in range(size):
        for x in range(size):
            # Create a simple pattern (circle or square)
            if (x - size//2)**2 + (y - size//2)**2 <= (size//2 - 4)**2:
                pixels.append(list(color))  # Fill circle
            else:
                pixels.append([0, 0, 0])  # Transparent background
    
    create_png(filename, size, size, pixels)

def main():
    print("Generating placeholder assets...")
    print()
    
    # Create assets directory structure
    asset_dirs = [
        'assets/audio/sfx',
        'assets/audio/music',
        'assets/audio/voices',
        'assets/sprites/robots',
        'assets/sprites/buildings',
        'assets/sprites/vehicles',
    ]
    
    for d in asset_dirs:
        os.makedirs(d, exist_ok=True)
    
    # Generate audio files
    print("Generating audio placeholders...")
    sfx_files = [
        'button_click.ogg', 'ui_click.ogg', 'ui_select.ogg',
        'territory_capture.ogg', 'explosion_small.ogg',
        'explosion_medium.ogg', 'explosion_large.ogg',
        'unit_death.ogg', 'vehicle_explosion.ogg',
        'gunshot_light.ogg', 'gunshot_heavy.ogg',
        'tank_fire.ogg', 'cannon_fire.ogg',
        'missile_launch.ogg', 'gatling_fire.ogg',
        'jeep_fire.ogg', 'metal_crash.ogg',
    ]
    
    for filename in sfx_files:
        filepath = f'assets/audio/sfx/{filename}'
        create_placeholder_audio(filepath)
    
    music_files = [
        'menu_theme.ogg', 'action_loop.ogg', 'battle_theme.ogg',
    ]
    
    for filename in music_files:
        filepath = f'assets/audio/music/{filename}'
        create_placeholder_audio(filepath, duration=3.0, frequency=220)
    
    # Generate voice barks (minimal)
    print("\nGenerating voice barks...")
    voice_types = ['attack', 'defend', 'move', 'retreat', 'stop', 'yes', 'no', 'confirm']
    teams = ['red', 'blue', 'neutral']
    
    for vtype in voice_types:
        for team in teams:
            # Create just one file per type/team
            filepath = f'assets/audio/voices/{vtype}/{team}/0.ogg'
            create_placeholder_audio(filepath, duration=0.2, frequency=300)
    
    # Generate sprites
    print("\nGenerating sprite placeholders...")
    
    # Robot buildings
    robot_sprites = [
        ('robot/robot_0.png', GRAY),
        ('vehicle/tank_0.png', BLUE),
    ]
    
    for path, color in robot_sprites:
        filepath = f'assets/sprites/{path}'
        os.makedirs(os.path.dirname(filepath), exist_ok=True)
        create_placeholder_sprite(filepath, size=32, color=color)
    
    # Flag sprites
    flag_colors = [('flag_blue_n00.png', BLUE), ('flag_red_n00.png', RED), ('flag_green_n00.png', GREEN)]
    
    for path, color in flag_colors:
        filepath = f'assets/sprites/buildings/{path}'
        os.makedirs(os.path.dirname(filepath), exist_ok=True)
        create_placeholder_sprite(filepath, size=16, color=color)
    
    # Unit sprites (minimal - just base frame)
    unit_types = ['grunt', 'psycho', 'sniper', 'laser', 'tough', 'commander']
    
    for unit in unit_types:
        # Just create one base frame per unit
        filepath = f'assets/sprites/robots/{unit}/base_red_n00.png'
        os.makedirs(os.path.dirname(filepath), exist_ok=True)
        create_placeholder_sprite(filepath, size=16, color=RED)
    
    print("\nDone! All placeholder assets generated.")
    print("\nTo use in Godot:")
    print("1. Import the project in Godot Editor")
    print("2. All .uid files will be regenerated")
    print("3. The game should run with placeholder graphics/audio")

if __name__ == '__main__':
    main()
