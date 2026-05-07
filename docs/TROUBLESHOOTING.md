# Troubleshooting Guide

Common issues and their solutions.

---

## Arduino Issues

### Arduino IDE: "Port not selected"
**Error:** `Serial port /dev/ttyACM0 not found`

**Solutions:**
1. Check the USB cable is properly connected
2. Try a different USB port on your computer
3. Look for drivers:
   - CH340 chips (cheap clones): Download from manufacturer website
   - Genuine Arduino: Usually auto-detected

```bash
# Linux: Check if device appears
dmesg | tail -20
ls /dev/tty*
```

---

### Arduino IDE: "Upload failed"
**Error:** `avrdude: stk500_recv(): programmer is not responding`

**Solutions:**
1. Check **Tools → Board** matches your hardware
2. Check **Tools → Port** is correct
3. Press the reset button on Arduino, then upload immediately
4. Try a different USB cable
5. Reinstall board drivers

---

### Arduino: "Baud rate mismatch"
**Problem:** Serial monitor shows garbage characters

**Solutions:**
```cpp
// In Arduino code, verify this matches Serial Monitor setting:
Serial.begin(9600);  // 9600 baud

// In Serial Monitor: Select the same baud rate from dropdown
```

---

### Arduino: Button doesn't work
**Problem:** Button press not detected

**Diagnostics:**
```cpp
// Add this to loop() and check Serial Monitor
Serial.println(digitalRead(2));  // Should print 0 and 1
```

**Solutions:**
1. Check wiring:
   - One side to Pin 2
   - Other side to GND
2. Test with multimeter (should read ~0V to 5V)
3. Try adding a pull-up resistor (10kΩ)
4. Swap button to different pin and update code

---

### Arduino: LED doesn't light
**Problem:** LED never turns on

**Diagnostics:**
```cpp
// Test with this code
void setup() {
  pinMode(13, OUTPUT);
}

void loop() {
  digitalWrite(13, HIGH);
  delay(1000);
  digitalWrite(13, LOW);
  delay(1000);
}
```

**Solutions:**
1. Check LED polarity:
   - Longer leg = Positive (to resistor)
   - Shorter leg = Negative (to GND)
2. Check 220Ω resistor is connected
3. Verify connections with multimeter
4. Try a different LED

---

### Arduino: No sound from buzzer
**Problem:** Buzzer is silent

**Diagnostics:**
```cpp
// Test tone function
tone(8, 1000, 500);  // Should beep
delay(500);
noTone(8);
```

**Solutions:**
1. Check buzzer polarity
2. Verify Pin 8 connection
3. Check piezo buzzer is 5V compatible
4. Try higher frequencies (1000-2000 Hz)
5. Test with:
   ```cpp
   for (int i = 500; i <= 2000; i += 100) {
     tone(8, i, 100);
     delay(150);
   }
   ```

---

## Raspberry Pi Issues

### No sound output
**Problem:** Speaker is silent

**Diagnostics:**
```bash
# Test 1: System recognizes sound device
aplay -l

# Test 2: Generate test tone
speaker-test -t sine -f 1000 -l 1

# Test 3: Check volume levels
alsamixer
```

**Solutions:**
1. **Check volume:**
   ```bash
   alsamixer  # Use arrow keys to increase
   amixer sget Master
   amixer sset PCM 100%
   ```

2. **Verify audio output:**
   ```bash
   # If using 3.5mm jack:
   amixer cset numid=3 1  # Enable 3.5mm output
   
   # If using HDMI:
   amixer cset numid=3 2  # Enable HDMI output
   ```

3. **Test different speaker:**
   - Original speaker might be faulty

4. **Check audio device:**
   ```bash
   # List audio devices
   pactl list short sinks
   
   # Set default device
   pactl set-default-sink <device_name>
   ```

---

### "aplay not found"
**Error:** `command not found: aplay`

**Solution:**
```bash
sudo apt-get install alsa-utils
```

---

### Serial connection "Permission denied"
**Error:** `Permission denied: '/dev/ttyACM0'`

**Solutions:**
```bash
# Option 1: Add user to dialout group
sudo usermod -a -G dialout $USER

# Then logout and login again
logout

# Option 2: Use sudo (temporary)
sudo python3 serial_listener.py test.wav

# Option 3: Change permissions (not recommended)
sudo chmod 666 /dev/ttyACM0
```

---

### "No module named 'serial'"
**Error:** `ModuleNotFoundError: No module named 'serial'`

**Solution:**
```bash
# Install PySerial
pip3 install pyserial

# Verify installation
python3 -c "import serial; print(serial.__version__)"
```

---

### "No module named 'pygame'"
**Error:** `ModuleNotFoundError: No module named 'pygame'`

**Solution:**
```bash
# Install Pygame
pip3 install pygame

# For Raspberry Pi (build from source if needed):
sudo apt-get install python3-pygame
```

---

## Python Script Issues

### Script: "File not found"
**Error:** `Error: File not found: test.wav`

**Solutions:**
1. Check file is in current directory
2. Use absolute path:
   ```bash
   python3 play_audio.py /home/pi/audio/test.wav
   ```
3. Create test file:
   ```bash
   speaker-test -t sine -f 1000 -l 1 > test.wav
   ```

---

### Script: "Arduino not detected"
**Error:** `Failed to connect: [Errno 2] could not open port /dev/ttyACM0`

**Diagnostics:**
```bash
# List serial ports
ls /dev/ttyACM*
ls /dev/ttyUSB*

# Check what's connected
dmesg | grep -i usb | tail -10
```

**Solutions:**
1. Verify Arduino is connected via USB
2. Find correct port number
3. Update script with correct port
4. Wait 2-3 seconds after connecting Arduino before running script

---

### Script hangs or freezes
**Problem:** Python script becomes unresponsive

**Solutions:**
```bash
# Stop the script
Ctrl+C

# Run with timeout
timeout 30 python3 serial_listener.py test.wav
```

**Debug:**
```bash
# Run with verbose output
python3 -u -v serial_listener.py test.wav
```

---

## Integration Issues

### Arduino → Pi communication fails
**Problem:** Serial messages not received

**Diagnostics:**
```bash
# Check if Python receives anything
python3 -c "
import serial
ser = serial.Serial('/dev/ttyACM0', 9600, timeout=1)
print('Waiting for data...')
for i in range(10):
    if ser.in_waiting:
        print(ser.readline())
"

# Check Arduino is sending data
# Open Serial Monitor in Arduino IDE
```

**Solutions:**
1. Verify baud rate matches (9600)
2. Ensure Arduino sketch has `Serial.begin(9600)`
3. Check USB cable is data cable, not charge-only
4. Add delay after `Serial.println()` in Arduino

---

### Audio plays but doesn't stop
**Problem:** Audio loops infinitely or runs in background

**Solutions:**
```bash
# Kill running audio processes
killall aplay
killall mpg123

# Kill Python script
pkill -f serial_listener.py
```

---

### High CPU usage
**Problem:** Python script uses too much CPU

**Solutions:**
1. Add delay in listen loop:
   ```python
   while self.running:
       if self.ser.in_waiting > 0:
           # ... process data ...
       time.sleep(0.01)  # 10ms delay
   ```

2. Reduce Serial polling rate

---

## Performance Tips

### Optimize Arduino:
```cpp
// Don't use Serial unnecessarily in loop
// Use digitalWrite instead of analogWrite when possible
// Debounce buttons in hardware (capacitor) not software
```

### Optimize Raspberry Pi:
```bash
# Disable unnecessary services
sudo systemctl disable bluetooth
sudo systemctl disable hciuart

# Use lightweight player (aplay over mpg123)
```

---

## Getting Help

If you still have issues:

1. **Check GitHub Issues:** https://github.com/gctjvq4kbr-coder/echo/issues
2. **Arduino Forums:** https://forum.arduino.cc
3. **Raspberry Pi Forums:** https://forums.raspberrypi.com
4. **Stack Overflow:** Tag with `arduino` and `python`

When reporting issues, include:
- Arduino board model
- Raspberry Pi model
- Python version: `python3 --version`
- OS: `uname -a`
- Error message (full text)
- Steps to reproduce
- Wiring diagram or photo
