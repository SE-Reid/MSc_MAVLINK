# Connecting to MSc_MAVLINKRouting from Another Laptop

This guide explains how to connect to the MAVLink stream from a laptop on the same network as your Raspberry Pi.

## Configuration Overview

After the recent update, both outputs are now UDP-based:
- **External Port (5760)**: For Ground Control Station connections from laptops
- **Internal Port (14560)**: For companion computer or other local applications

## Finding Your Pi's IP Address

On your Raspberry Pi, find the IP address:
```bash
# Method 1: Using hostname
hostname -I

# Method 2: Using ip command
ip addr show wlan0 | grep inet

# Method 3: Using ifconfig
ifconfig wlan0 | grep inet
```

Example output: `192.168.1.100`

## Connecting from Your Laptop

### Option 1: Using Mission Planner (Windows)
1. Open Mission Planner
2. In the connection dropdown, select **UDP**
3. Click **Connect**
4. In the UDP connection dialog:
   - **Local Port**: `14550` (Mission Planner's default)
   - **Remote Host**: `192.168.1.100` (your Pi's IP)
   - **Remote Port**: `5760`
5. Click **Connect**

### Option 2: Using QGroundControl (Cross-platform)
1. Open QGroundControl
2. Go to **Application Settings** > **Comm Links**
3. Click **Add** to create a new connection
4. Set up the connection:
   - **Type**: UDP
   - **Listening Port**: `14550`
   - **Target Hosts**: `192.168.1.100:5760` (Pi IP:Port)
5. **Connect** to the link

### Option 3: Using MAVProxy on Laptop
```bash
# Install MAVProxy if not already installed
pip install MAVProxy

# Connect to Pi's UDP stream
mavproxy.py --master=udp:192.168.1.100:5760
```

### Option 4: Using MAVSDK or DroneKit
```python
# Python example with MAVSDK
from mavsdk import System

async def connect_to_pi():
    drone = System()
    await drone.connect(system_address="udp://192.168.1.100:5760")
    # Your drone control code here

# Python example with DroneKit
from dronekit import connect
vehicle = connect('udp:192.168.1.100:5760', wait_ready=True)
```

## Network Configuration

### On the Raspberry Pi
The service automatically binds to all network interfaces (`0.0.0.0`), so it accepts connections from any device on the network.

### Firewall Considerations
If you have firewall issues, you may need to:

**On Raspberry Pi:**
```bash
# Allow incoming connections on the MAVLink ports
sudo ufw allow 5760/udp
sudo ufw allow 14560/udp
```

**On your laptop:** Most firewalls allow outgoing UDP connections by default.

## Testing the Connection

### From Your Laptop
Test if the Pi is reachable:
```bash
# Test network connectivity
ping 192.168.1.100

# Test if the port is open (if netcat is available)
nc -u 192.168.1.100 5760
```

### On the Raspberry Pi
Check if the service is running:
```bash
# Check service status
sudo systemctl status mavlink-router

# Check if ports are open
sudo netstat -ulnp | grep -E "(5760|14560)"

# View live logs
sudo journalctl -u mavlink-router -f
```

## Troubleshooting

### Connection Issues
1. **Verify Pi IP address** - ensure you're using the correct IP
2. **Check network connectivity** - ping the Pi from your laptop
3. **Verify service is running** - check systemctl status
4. **Check firewall settings** - ensure UDP ports are open
5. **Try different GCS software** - test with multiple applications

### Multiple Connections
UDP allows multiple clients to connect simultaneously:
- Your laptop can connect to port 5760
- Companion computer can connect to port 14560
- Multiple GCS applications can connect to the same port

### Common Port Configurations
- **5760**: Standard GCS connection port
- **14560**: Standard companion computer port  
- **14550**: Mission Planner default listening port

## Example Network Setup

```
Internet Router (192.168.1.1)
├── Raspberry Pi (192.168.1.100) - Running MSc_MAVLINKRouting
├── Your Laptop (192.168.1.50) - Running Mission Planner/QGC
└── Companion Computer (192.168.1.200) - Optional
```

**Connection Flow:**
1. Drone → UART → Raspberry Pi (MAVLink Router)
2. Raspberry Pi → UDP:5760 → Your Laptop (GCS)
3. Raspberry Pi → UDP:14560 → Companion Computer (optional)

This setup allows real-time MAVLink data streaming to multiple devices simultaneously over your local network!
