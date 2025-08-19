#!/bin/bash

# MAVLink Router Installation Script
set -e

echo "=== MSc_MAVLINKRouting Installation ==="

# Get the directory where this script is located
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$SCRIPT_DIR"

echo "Script directory: $SCRIPT_DIR"
echo "Project root: $PROJECT_ROOT"

# Configuration
INSTALL_DIR="/opt/mavlink"
SERVICE_DIR="/etc/systemd/system"
USER="mavlink"
GROUP="mavlink"

# Source file paths
SRC_DIR="$PROJECT_ROOT/src"
SYSTEMD_DIR="$PROJECT_ROOT/systemd"

# Check if running as root
if [ "$EUID" -ne 0 ]; then
    echo "Please run this script as root (sudo)"
    exit 1
fi

# Verify source files exist
echo "Checking source files..."
if [ ! -f "$SRC_DIR/start_mavlink.sh" ]; then
    echo "ERROR: start_mavlink.sh not found at $SRC_DIR/start_mavlink.sh"
    exit 1
fi

if [ ! -f "$SRC_DIR/heartbeat_monitor.py" ]; then
    echo "ERROR: heartbeat_monitor.py not found at $SRC_DIR/heartbeat_monitor.py"
    exit 1
fi

if [ ! -f "$SYSTEMD_DIR/mavlink-router.service" ]; then
    echo "ERROR: mavlink-router.service not found at $SYSTEMD_DIR/mavlink-router.service"
    exit 1
fi

if [ ! -f "$SYSTEMD_DIR/mavlink-heartbeat.service" ]; then
    echo "ERROR: mavlink-heartbeat.service not found at $SYSTEMD_DIR/mavlink-heartbeat.service"
    exit 1
fi

echo "All source files found."

echo "Creating user and group..."
# Create mavlink user if it doesn't exist
if ! id "$USER" &>/dev/null; then
    useradd -r -s /bin/bash -d "$INSTALL_DIR" -m "$USER"
    echo "Created user: $USER"
else
    echo "User $USER already exists"
fi

# Add user to dialout group for serial access
usermod -a -G dialout "$USER"

echo "Setting up directories..."
# Create directories
mkdir -p "$INSTALL_DIR"
mkdir -p /var/log/mavlink
chown -R "$USER:$GROUP" "$INSTALL_DIR"
chown -R "$USER:$GROUP" /var/log/mavlink

echo "Copying files..."
# Copy files to installation directory
cp "$SRC_DIR/start_mavlink.sh" "$INSTALL_DIR/"
cp "$SRC_DIR/heartbeat_monitor.py" "$INSTALL_DIR/"
cp "$SRC_DIR/config.env.template" "$INSTALL_DIR/"

# Copy configuration if it doesn't exist
if [ ! -f "$INSTALL_DIR/config.env" ]; then
    cp "$SRC_DIR/config.env.template" "$INSTALL_DIR/config.env"
    echo "Created default config.env from template"
fi

# Make scripts executable
chmod +x "$INSTALL_DIR/start_mavlink.sh"
chmod +x "$INSTALL_DIR/heartbeat_monitor.py"
chown -R "$USER:$GROUP" "$INSTALL_DIR"

echo "Installing systemd services..."
# Install systemd services
cp "$SYSTEMD_DIR/mavlink-router.service" "$SERVICE_DIR/"
cp "$SYSTEMD_DIR/mavlink-heartbeat.service" "$SERVICE_DIR/"

# Reload systemd
systemctl daemon-reload

echo "Setting up Python environment..."
# Install required Python packages
apt-get update
apt-get install -y python3 python3-pip python3-venv

# Create virtual environment for mavlink user
sudo -u "$USER" python3 -m venv "$INSTALL_DIR/mavlink-venv"
sudo -u "$USER" "$INSTALL_DIR/mavlink-venv/bin/pip" install --upgrade pip
sudo -u "$USER" "$INSTALL_DIR/mavlink-venv/bin/pip" install MAVProxy pymavlink

echo "Installation complete!"
echo ""
echo "Next steps:"
echo "1. Edit $INSTALL_DIR/config.env for your device configuration"
echo "2. Enable and start the services:"
echo "   sudo systemctl enable mavlink-router.service"
echo "   sudo systemctl enable mavlink-heartbeat.service"
echo "   sudo systemctl start mavlink-router.service"
echo "   sudo systemctl start mavlink-heartbeat.service"
echo ""
echo "Monitor the services with:"
echo "   sudo journalctl -u mavlink-router -f"
echo "   sudo journalctl -u mavlink-heartbeat -f"
echo ""
echo "Check status with:"
echo "   sudo systemctl status mavlink-router"
echo "   sudo systemctl status mavlink-heartbeat"
