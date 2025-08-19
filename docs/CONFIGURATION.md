# Interactive Configuration Example

This document shows what the interactive configuration process looks like when you run `sudo ./scripts/deploy.sh`.

## Example Session

```bash
pi@raspberrypi:/tmp/MSc_MAVLINKRouting $ sudo ./scripts/deploy.sh

=== MSc_MAVLINKRouting Deployment ===
Project root: /tmp/MSc_MAVLINKRouting
Detected target system (Linux with systemd)
Running installation on target system...

=== Configuration Setup ===
No configuration found. Creating from template...

=== Interactive Configuration ===
Configure your MAVLink router settings:

--- Serial Connection ---
UART Device [/dev/ttyAMA0]: /dev/ttyUSB0
Baud Rate [57600]: 115200

--- Network Settings ---
External UDP Port (for GCS connections) [5760]: 
Internal UDP Port (for companion computer) [14560]: 14561

--- Device Identification ---
Device ID [1]: 2
Device Name [MSc_MAVLINKRouter]: DroneRouter-Lab

--- Network Information ---
Detected Pi IP: 192.168.1.150
GCS Connection: udp:192.168.1.150:5760
Companion Connection: udp:192.168.1.150:14561

Writing configuration to /tmp/MSc_MAVLINKRouting/src/config.env...
Configuration saved!

Final configuration:
===================
# MAVLink Router Configuration
# Generated on Mon Aug 19 10:30:45 UTC 2025

# Serial connection settings
UART_DEVICE=/dev/ttyUSB0
BAUD_RATE=115200

# Network ports
EXTERNAL_PORT=5760
INTERNAL_PORT=14561

# Device identification
DEVICE_ID=2
DEVICE_NAME="DroneRouter-Lab"

# Network info (for reference)
# Pi IP: 192.168.1.150
# GCS Connection: udp:192.168.1.150:5760
# Companion Connection: udp:192.168.1.150:14561
===================

Press Enter to continue with installation...

=== MSc_MAVLINKRouting Installation ===
Script directory: /tmp/MSc_MAVLINKRouting/src
Project root: /tmp/MSc_MAVLINKRouting
Checking source files...
All source files found.
Creating user and group...
[Installation continues...]
```

## Configuration Options Explained

### Serial Connection
- **UART Device**: The serial port connected to your flight controller
  - Common options: `/dev/ttyAMA0` (Pi UART), `/dev/ttyUSB0` (USB adapter)
- **Baud Rate**: Communication speed with flight controller
  - Common options: `57600`, `115200`, `921600`

### Network Settings
- **External Port**: UDP port for Ground Control Station connections from laptops
  - Default: `5760` (standard GCS port)
- **Internal Port**: UDP port for companion computer connections
  - Default: `14560` (standard companion port)

### Device Identification
- **Device ID**: Unique identifier for this router instance
- **Device Name**: Human-readable name for logging and identification

### Network Information
The script automatically detects your Pi's IP address and shows you the exact connection strings to use in your Ground Control Station software.

## Using the Configuration

After configuration, you can connect from your laptop using:

**Mission Planner**: UDP connection to `192.168.1.150:5760`
**QGroundControl**: Add UDP link with target `192.168.1.150:5760`
**MAVProxy**: `mavproxy.py --master=udp:192.168.1.150:5760`

## Skipping Interactive Configuration

If you want to use defaults or have already configured the system:

```bash
sudo ./scripts/deploy.sh --skip-config
```

This will use the existing configuration or create one from the template with default values.
