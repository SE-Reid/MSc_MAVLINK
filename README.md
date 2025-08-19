# MSc_MAVLINKRouting

A robust MAVLink routing service for Raspberry Pi with automatic heartbeat monitoring and restart capabilities.

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Release](https://img.shields.io/github/v/release/your-username/MSc_MAVLINKRouting)](https://github.com/your-username/MSc_MAVLINKRouting/releases)
![GitHub Actions Workflow Status](https://img.shields.io/github/actions/workflow/status/se-reid/MSc_MAVLINK/ci.yml)

## Project Structure

```
MSc_MAVLINKRouting/
├── docs/                    # Documentation
│   ├── README.md           # Detailed documentation  
│   └── QUICKSTART.md       # Quick start guide
├── scripts/                # Deployment and utility scripts
│   └── deploy.sh          # Development deployment script
├── src/                    # Source files
│   ├── heartbeat_monitor.py    # Heartbeat monitoring service
│   ├── start_mavlink.sh        # MAVLink startup script
│   ├── config.env.template     # Configuration template
│   └── config.env             # Local configuration (if exists)
├── systemd/                # Systemd service files
│   ├── mavlink-router.service     # Main router service
│   └── mavlink-heartbeat.service  # Heartbeat monitor service
├── install.sh             # Installation script
└── README.md              # This file
```

## Features

- **Auto-start on boot**: Systemd service starts MAVProxy routing automatically
- **Heartbeat monitoring**: Automatically restarts service if heartbeat is lost for 30+ seconds
- **Device-specific configuration**: Easy per-device configuration via environment files
- **Robust error handling**: Comprehensive logging and error recovery
- **Security**: Runs as dedicated user with minimal privileges

## Quick Installation

### On Raspberry Pi (Target System)

1. Copy this entire directory to your Raspberry Pi
2. Run the deployment with interactive configuration:
   ```bash
   sudo ./scripts/deploy.sh
   ```
   This will guide you through configuring UART device, baud rates, and network ports.

3. Enable and start the services:
   ```bash
   sudo systemctl enable mavlink-router.service mavlink-heartbeat.service
   sudo systemctl start mavlink-router.service mavlink-heartbeat.service
   ```

**Alternative**: Skip interactive setup:
```bash
sudo ./scripts/deploy.sh --skip-config
sudo nano /opt/mavlink/config.env  # Edit manually if needed
```

### From Development System

1. Use the deployment script to check files and get copy instructions:
   ```bash
   ./scripts/deploy.sh
   ```

2. Copy to your Pi:
   ```bash
   scp -r . pi@your-pi-ip:/tmp/MSc_MAVLINKRouting
   ```

3. SSH to Pi and install:
   ```bash
   ssh pi@your-pi-ip
   cd /tmp/MSc_MAVLINKRouting
   sudo ./install.sh
   ```

## Configuration

Edit `/opt/mavlink/config.env`:

```bash
# Serial connection
UART_DEVICE=/dev/ttyAMA0
BAUD_RATE=57600

# Network ports
EXTERNAL_PORT=5760    # UDP port for GCS connections
INTERNAL_PORT=14560   # UDP port for companion computer

# Device identification
DEVICE_ID=1
DEVICE_NAME="PiRouter"
```

## Monitoring

Check service status:
```bash
sudo systemctl status mavlink-router mavlink-heartbeat
```

View logs:
```bash
sudo journalctl -u mavlink-router -f
sudo journalctl -u mavlink-heartbeat -f
```

## File Locations After Installation

- **Runtime files**: `/opt/mavlink/`
- **Configuration**: `/opt/mavlink/config.env`
- **Logs**: `/var/log/mavlink/`
- **Service files**: `/etc/systemd/system/mavlink-*.service`

## Development

- **Source files**: `src/` directory contains all runtime components
- **Services**: `systemd/` directory contains service definitions
- **Scripts**: `scripts/` directory contains deployment helpers
- **Documentation**: `docs/` directory contains detailed docs

For detailed documentation, see `docs/README.md`.

## Network Connections

Connect from another laptop using the Pi's IP address:
- **Mission Planner/QGroundControl**: UDP connection to `PI_IP:5760`
- **MAVProxy**: `mavproxy.py --master=udp:PI_IP:5760`
- **Custom apps**: Connect to `udp://PI_IP:5760`

See `docs/NETWORK_SETUP.md` for complete connection guide.

## Contributing

Contributions are welcome! Please see [CONTRIBUTING.md](CONTRIBUTING.md) for guidelines.

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Security

For security concerns, please see [SECURITY.md](SECURITY.md).

## Changelog

See [CHANGELOG.md](CHANGELOG.md) for version history and changes.
