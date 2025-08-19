#!/bin/bash

# MAVLink routing startup script
set -e  # Exit on any error

# Set working directory
cd /opt/mavlink

# Configuration
VENV_PATH="/opt/mavlink/mavlink-venv"
CONFIG_FILE="/opt/mavlink/config.env"
LOG_DIR="/var/log/mavlink"

# Create log directory if it doesn't exist
mkdir -p ${LOG_DIR}

# Source configuration
if [ -f "${CONFIG_FILE}" ]; then
    source "${CONFIG_FILE}"
    echo "Loaded configuration from ${CONFIG_FILE}"
else
    echo "ERROR: Configuration file ${CONFIG_FILE} not found"
    exit 1
fi

# Activate virtual environment if it exists
if [ -d "${VENV_PATH}" ]; then
    source "${VENV_PATH}/bin/activate"
    echo "Activated virtual environment: ${VENV_PATH}"
else
    echo "WARNING: Virtual environment not found at ${VENV_PATH}, using system Python"
fi

# Validate required variables
if [ -z "${UART_DEVICE}" ] || [ -z "${BAUD_RATE}" ] || [ -z "${EXTERNAL_PORT}" ] || [ -z "${INTERNAL_PORT}" ]; then
    echo "ERROR: Missing required configuration variables"
    echo "UART_DEVICE=${UART_DEVICE}"
    echo "BAUD_RATE=${BAUD_RATE}"
    echo "EXTERNAL_PORT=${EXTERNAL_PORT}"
    echo "INTERNAL_PORT=${INTERNAL_PORT}"
    exit 1
fi

# Wait for UART Connection
echo "Waiting for UART device ${UART_DEVICE}..."
WAIT_COUNT=0
while [ ${WAIT_COUNT} -lt 30 ]; do
    if [ -c "${UART_DEVICE}" ]; then
        # Check if we can access the device
        if timeout 5 stty -F "${UART_DEVICE}" speed "${BAUD_RATE}" 2>/dev/null; then
            echo "Device ${UART_DEVICE} is ready and accessible"
            break
        else
            echo "Device ${UART_DEVICE} exists but is not accessible... (${WAIT_COUNT}/30)"
        fi
    else
        echo "Waiting for ${UART_DEVICE}... (${WAIT_COUNT}/30)"
    fi
    sleep 2
    WAIT_COUNT=$((WAIT_COUNT + 1))
done

if [ ${WAIT_COUNT} -eq 30 ]; then
    echo "ERROR: ${UART_DEVICE} not ready after 60 seconds"
    echo "Device details:"
    ls -la "${UART_DEVICE}" 2>/dev/null || echo "Device does not exist"
    echo "User groups: $(groups)"
    echo "Available serial devices:"
    ls -la /dev/tty* | grep -E "(USB|ACM|AMA)" || echo "No serial devices found"
    exit 1
fi

echo "Starting MAVProxy with configuration:"
echo "  Master: ${UART_DEVICE}@${BAUD_RATE}"
echo "  External UDP: 0.0.0.0:${EXTERNAL_PORT}"
echo "  Internal UDP: 0.0.0.0:${INTERNAL_PORT}"
echo "  Log directory: ${LOG_DIR}"

# Start MAVProxy with routing - non-interactive mode
exec mavproxy.py \
    --master="${UART_DEVICE}" \
    --baudrate="${BAUD_RATE}" \
    --out="udp:0.0.0.0:${EXTERNAL_PORT}" \
    --out="udp:0.0.0.0:${INTERNAL_PORT}" \
    --state-basedir="${LOG_DIR}" \
    --aircraft="router" \
    --daemon \
    --non-interactive \
    --logfile="${LOG_DIR}/mavproxy.log"
