#!/bin/bash

# MSc_MAVLINKRouting Deployment Script
# Run this script to deploy files to a Raspberry Pi

set -e

# Parse command line arguments
SKIP_CONFIG=false
while [[ $# -gt 0 ]]; do
    case $1 in
        --skip-config)
            SKIP_CONFIG=true
            shift
            ;;
        -h|--help)
            echo "Usage: $0 [--skip-config] [--help]"
            echo "  --skip-config  Skip interactive configuration"
            echo "  --help         Show this help message"
            exit 0
            ;;
        *)
            echo "Unknown option: $1"
            echo "Use --help for usage information"
            exit 1
            ;;
    esac
done

# Get the directory where this script is located
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

echo "=== MSc_MAVLINKRouting Deployment ==="
echo "Project root: $PROJECT_ROOT"

# Configuration function
configure_system() {
    echo ""
    echo "=== Interactive Configuration ==="
    
    # Load current values
    if [ -f "$CONFIG_FILE" ]; then
        source "$CONFIG_FILE"
    fi
    
    # Set defaults if not loaded
    UART_DEVICE=${UART_DEVICE:-/dev/ttyAMA0}
    BAUD_RATE=${BAUD_RATE:-57600}
    EXTERNAL_PORT=${EXTERNAL_PORT:-5760}
    INTERNAL_PORT=${INTERNAL_PORT:-14560}
    DEVICE_ID=${DEVICE_ID:-1}
    DEVICE_NAME=${DEVICE_NAME:-MSc_MAVLINKRouter}
    
    echo "Configure your MAVLink router settings:"
    echo ""
    
    # Serial connection settings
    echo "--- Serial Connection ---"
    read -p "UART Device [$UART_DEVICE]: " input
    UART_DEVICE=${input:-$UART_DEVICE}
    
    read -p "Baud Rate [$BAUD_RATE]: " input
    BAUD_RATE=${input:-$BAUD_RATE}
    
    # Network settings
    echo ""
    echo "--- Network Settings ---"
    read -p "External UDP Port (for GCS connections) [$EXTERNAL_PORT]: " input
    EXTERNAL_PORT=${input:-$EXTERNAL_PORT}
    
    read -p "Internal UDP Port (for companion computer) [$INTERNAL_PORT]: " input
    INTERNAL_PORT=${input:-$INTERNAL_PORT}
    
    # Device identification
    echo ""
    echo "--- Device Identification ---"
    read -p "Device ID [$DEVICE_ID]: " input
    DEVICE_ID=${input:-$DEVICE_ID}
    
    read -p "Device Name [$DEVICE_NAME]: " input
    DEVICE_NAME=${input:-$DEVICE_NAME}
    
    # Network detection
    echo ""
    echo "--- Network Information ---"
    PI_IP=$(hostname -I | awk '{print $1}')
    echo "Detected Pi IP: $PI_IP"
    echo "GCS Connection: udp:$PI_IP:$EXTERNAL_PORT"
    echo "Companion Connection: udp:$PI_IP:$INTERNAL_PORT"
    
    # Write configuration
    echo ""
    echo "Writing configuration to $CONFIG_FILE..."
    cat > "$CONFIG_FILE" << EOF
# MAVLink Router Configuration
# Generated on $(date)

# Serial connection settings
UART_DEVICE=$UART_DEVICE
BAUD_RATE=$BAUD_RATE

# Network ports
EXTERNAL_PORT=$EXTERNAL_PORT
INTERNAL_PORT=$INTERNAL_PORT

# Device identification
DEVICE_ID=$DEVICE_ID
DEVICE_NAME="$DEVICE_NAME"

# Network info (for reference)
# Pi IP: $PI_IP
# GCS Connection: udp:$PI_IP:$EXTERNAL_PORT
# Companion Connection: udp:$PI_IP:$INTERNAL_PORT
EOF
    
    echo "Configuration saved!"
    echo ""
    echo "Final configuration:"
    echo "==================="
    cat "$CONFIG_FILE"
    echo "==================="
    echo ""
    read -p "Press Enter to continue with installation..."
}

# Check if we're on the target system or need to copy files
if [ -d "/opt" ] && [ -d "/etc/systemd" ]; then
    echo "Detected target system (Linux with systemd)"
    TARGET_MODE=true
else
    echo "Development system detected - files ready for transfer"
    TARGET_MODE=false
fi

if [ "$TARGET_MODE" = true ]; then
    # We're on the target system, run installation
    echo "Running installation on target system..."
    
    # Make sure we're running as root
    if [ "$EUID" -ne 0 ]; then
        echo "Please run as root: sudo $0"
        exit 1
    fi
    
    # Configuration setup
    if [ "$SKIP_CONFIG" = false ]; then
        echo ""
        echo "=== Configuration Setup ==="
        CONFIG_FILE="$PROJECT_ROOT/src/config.env"
        TEMPLATE_FILE="$PROJECT_ROOT/src/config.env.template"
        
        # Check if config already exists
        if [ -f "$CONFIG_FILE" ]; then
            echo "Existing configuration found."
            echo "Current settings:"
            echo "=================="
            cat "$CONFIG_FILE"
            echo "=================="
            echo ""
            read -p "Do you want to modify the configuration? (y/N): " modify_config
        else
            echo "No configuration found. Creating from template..."
            cp "$TEMPLATE_FILE" "$CONFIG_FILE"
            modify_config="y"
        fi
        
        if [[ "$modify_config" =~ ^[Yy]$ ]]; then
            configure_system
        fi
    else
        echo "Skipping interactive configuration (--skip-config specified)"
        # Ensure config exists
        CONFIG_FILE="$PROJECT_ROOT/src/config.env"
        TEMPLATE_FILE="$PROJECT_ROOT/src/config.env.template"
        if [ ! -f "$CONFIG_FILE" ]; then
            echo "Creating default configuration from template..."
            cp "$TEMPLATE_FILE" "$CONFIG_FILE"
        fi
    fi
    
    # Run the installation script
    bash "$PROJECT_ROOT/install.sh"
    
else
    # Development system - show transfer instructions
    echo ""
    echo "To deploy to your Raspberry Pi:"
    echo ""
    echo "1. Copy files to Pi:"
    echo "   scp -r $PROJECT_ROOT pi@your-pi-ip:/tmp/MSc_MAVLINKRouting"
    echo ""
    echo "2. SSH to Pi and run installation:"
    echo "   ssh pi@your-pi-ip"
    echo "   cd /tmp/MSc_MAVLINKRouting"
    echo "   sudo ./scripts/deploy.sh"
    echo ""
    echo "   Or skip interactive configuration:"
    echo "   sudo ./scripts/deploy.sh --skip-config"
    echo ""
    echo "Or use rsync for updates:"
    echo "   rsync -av --delete $PROJECT_ROOT/ pi@your-pi-ip:/tmp/MSc_MAVLINKRouting/"
    echo ""
    
    # Verify all required files exist
    echo "Verifying project files..."
    
    required_files=(
        "src/start_mavlink.sh"
        "src/heartbeat_monitor.py"
        "src/config.env.template"
        "install.sh"
        "systemd/mavlink-router.service"
        "systemd/mavlink-heartbeat.service"
        "docs/README.md"
        "docs/NETWORK_SETUP.md"
        "docs/CONFIGURATION.md"
        "LICENSE"
        "CHANGELOG.md"
        "CONTRIBUTING.md"
        ".gitignore"
    )
    
    missing_files=()
    for file in "${required_files[@]}"; do
        if [ ! -f "$PROJECT_ROOT/$file" ]; then
            missing_files+=("$file")
        fi
    done
    
    if [ ${#missing_files[@]} -eq 0 ]; then
        echo "✓ All required files present"
    else
        echo "✗ Missing files:"
        for file in "${missing_files[@]}"; do
            echo "  - $file"
        done
        exit 1
    fi
    
    echo ""
    echo "Project structure:"
    find "$PROJECT_ROOT" -type f -name "*.sh" -o -name "*.py" -o -name "*.service" -o -name "*.env*" -o -name "README.md" | sort
fi
