#!/bin/bash
set -e

echo "🔧 Setting up Arduino & Raspberry Pi Audio Development Environment..."

# Update system packages
echo "📦 Updating packages..."
apt-get update
apt-get install -y \
    build-essential \
    curl \
    git \
    wget \
    ffmpeg \
    alsa-utils \
    python3-dev

# Install Python dependencies
echo "🐍 Installing Python packages..."
pip install --upgrade pip
pip install \
    pyserial \
    pygame \
    pytest \
    black \
    pylint

# Create audio test directory
mkdir -p ./audio_files
echo "✅ Created audio_files directory"

# Install Arduino CLI (optional, for reference)
echo "🎛️  Installing Arduino CLI..."
curl -fsSL https://raw.githubusercontent.com/arduino/arduino-cli/master/install.sh | sh
./bin/arduino-cli version || true

# Create sample test audio file
echo "🔊 Creating test audio file..."
python3 << 'EOF'
import wave
import struct
import math

# Create a 1-second, 1000Hz tone
freq = 1000
sample_rate = 44100
duration = 1

with wave.open('audio_files/test.wav', 'w') as wav_file:
    wav_file.setnchannels(1)
    wav_file.setsampwidth(2)
    wav_file.setframerate(sample_rate)
    
    for i in range(int(sample_rate * duration)):
        value = int(32767 * 0.5 * math.sin(2 * math.pi * freq * i / sample_rate))
        wav_file.writeframes(struct.pack('<h', value))

print("✓ Test audio file created: audio_files/test.wav")
EOF

echo ""
echo "✨ Setup complete!"
echo ""
echo "📚 Next steps:"
echo "1. Review the README.md for project overview"
echo "2. Check docs/HARDWARE_SETUP.md for wiring"
echo "3. Check docs/INSTALLATION.md for setup steps"
echo ""
echo "📁 Project structure:"
echo "  arduino/          - Arduino sketches"
echo "  raspberry_pi/     - Python scripts for Raspberry Pi"
echo "  docs/             - Documentation (hardware, setup, troubleshooting)"
echo "  audio_files/      - Audio files (test.wav created)"
echo ""
echo "🚀 To get started:"
echo "  • Review arduino/button_triggered_audio.ino"
echo "  • Review raspberry_pi/serial_listener.py"
echo "  • Follow the installation guide in docs/INSTALLATION.md"
echo ""
