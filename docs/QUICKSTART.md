# Quick Start Guide

## For Development (Windows/Local)

1. **Verify files are ready**:
   ```bash
   ./scripts/deploy.sh
   ```

2. **Copy to Raspberry Pi**:
   ```bash
   scp -r . pi@your-pi-ip:/tmp/MSc_MAVLINKRouting
   ```

## For Installation (on Raspberry Pi)

1. **SSH to your Pi**:
   ```bash
   ssh pi@your-pi-ip
   ```

2. **Navigate to copied files**:
   ```bash
   cd /tmp/MSc_MAVLINKRouting
   ```

3. **Run deployment with interactive configuration**:
   ```bash
   sudo ./scripts/deploy.sh
   ```
   
   This will:
   - Allow you to configure UART device, baud rate, and ports
   - Show your Pi's IP address for GCS connections
   - Install the service with your custom settings

   **Alternative: Skip configuration prompts**:
   ```bash
   sudo ./scripts/deploy.sh --skip-config
   ```

   **Alternative: Manual installation**:
   ```bash
   sudo ./install.sh
   # Then manually edit: sudo nano /opt/mavlink/config.env
   ```

4. **Start services**:
   ```bash
   sudo systemctl enable mavlink-router.service mavlink-heartbeat.service
   sudo systemctl start mavlink-router.service mavlink-heartbeat.service
   ```

5. **Check status**:
   ```bash
   sudo systemctl status mavlink-router mavlink-heartbeat
   sudo journalctl -u mavlink-router -f
   ```

## Connecting from Your Laptop

After installation, you can connect to the MAVLink stream from another laptop:

1. **Find your Pi's IP address**:
   ```bash
   hostname -I
   ```

2. **Connect using Mission Planner**:
   - Connection Type: UDP
   - Remote Host: `192.168.1.100` (your Pi's IP)
   - Remote Port: `5760`

3. **Connect using QGroundControl**:
   - Add UDP connection
   - Target Host: `192.168.1.100:5760`

See `docs/NETWORK_SETUP.md` for detailed connection instructions.

## Directory Structure

After reorganization:
- `src/` - Source files to be installed
- `scripts/` - Deployment and utility scripts  
- `systemd/` - Service definitions
- `docs/` - Documentation
- `install.sh` - Main installation entry point

## Troubleshooting

If you get "cannot stat" errors, make sure you're running the script from the correct directory containing all the project files.

The install script automatically detects file locations and copies them from the project structure to the system locations.
