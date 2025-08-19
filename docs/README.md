# MAVLink Router Service

A robust MAVLink routing service for Raspberry Pi with automatic heartbeat monitoring and restart capabilities.

## Features

- **Auto-start on boot**: Systemd service starts MAVProxy routing automatically
- **Heartbeat monitoring**: Automatically restarts service if heartbeat is lost for 30+ seconds
- **Device-specific configuration**: Easy per-device configuration via environment files
- **Robust error handling**: Comprehensive logging and error recovery
- **Security**: Runs as dedicated user with minimal privileges

## Installation

1. Run the installation script as root:
   ```bash
   sudo ./install.sh
   ```

2. Edit the configuration file:
   ```bash
   sudo nano /opt/mavlink/config.env
   ```

3. Enable and start the services:
   ```bash
   sudo systemctl enable mavlink-router.service
   sudo systemctl enable mavlink-heartbeat.service
   sudo systemctl start mavlink-router.service
   sudo systemctl start mavlink-heartbeat.service
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
sudo systemctl status mavlink-router
sudo systemctl status mavlink-heartbeat
```

View real-time logs:
```bash
sudo journalctl -u mavlink-router -f
sudo journalctl -u mavlink-heartbeat -f
```

View log files:
```bash
tail -f /var/log/mavlink/mavproxy.log
tail -f /var/log/mavlink/heartbeat_monitor.log
```

## Troubleshooting

### Service fails to start

1. **Check device permissions**:
   ```bash
   ls -la /dev/ttyAMA0
   groups mavlink
   ```
   The mavlink user should be in the `dialout` group.

2. **Check configuration**:
   ```bash
   sudo -u mavlink cat /opt/mavlink/config.env
   ```

3. **Test serial device**:
   ```bash
   sudo -u mavlink stty -F /dev/ttyAMA0 57600
   ```

### MAVProxy dumps modules and exits

This usually happens when MAVProxy can't connect to the flight controller:

1. **Check serial connection**:
   - Ensure correct UART device path
   - Verify baud rate matches flight controller
   - Check wiring (TX/RX, ground)

2. **Check for conflicts**:
   ```bash
   sudo systemctl status serial-getty@ttyAMA0
   sudo systemctl disable serial-getty@ttyAMA0  # If needed
   ```

3. **Test manual connection**:
   ```bash
   sudo -u mavlink /opt/mavlink/mavlink-venv/bin/mavproxy.py --master=/dev/ttyAMA0 --baudrate=57600
   ```

### Heartbeat monitor not working

1. **Check UDP connectivity**:
   ```bash
   netstat -ulnp | grep 14560
   ```

2. **Test MAVLink output**:
   ```bash
   nc -u 127.0.0.1 14560
   ```

### Permission issues

1. **Fix ownership**:
   ```bash
   sudo chown -R mavlink:mavlink /opt/mavlink
   sudo chown -R mavlink:mavlink /var/log/mavlink
   ```

2. **Add to dialout group**:
   ```bash
   sudo usermod -a -G dialout mavlink
   ```

## Network Ports

- **TCP 5760**: External connections (Ground Control Stations)
- **UDP 14560**: Internal connections (Companion computer applications)
- **UDP 14561**: Heartbeat monitor (internal)

## File Locations

- Configuration: `/opt/mavlink/config.env`
- Scripts: `/opt/mavlink/`
- Logs: `/var/log/mavlink/`
- Services: `/etc/systemd/system/mavlink-*.service`

## Customization

### Adding MAVProxy modules

Edit `/opt/mavlink/config.env` and add:
```bash
MAVPROXY_EXTRA_ARGS="--load-module=terrain,rally,adsb"
```

### Changing log levels

Edit `/opt/mavlink/config.env`:
```bash
LOG_LEVEL=DEBUG
```

### Multiple devices

Copy the entire configuration and modify device-specific settings:
```bash
sudo cp -r /opt/mavlink /opt/mavlink-device2
sudo nano /opt/mavlink-device2/config.env
```

Create device-specific service files by copying and modifying the existing ones.
