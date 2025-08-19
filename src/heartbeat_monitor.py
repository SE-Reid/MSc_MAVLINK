#!/usr/bin/env python3
"""
MAVLink Heartbeat Monitor
Monitors MAVLink heartbeat and restarts service if connection is lost for 30+ seconds
"""

import time
import socket
import struct
import subprocess
import logging
import sys
import os
from datetime import datetime, timedelta

# Setup logging
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(levelname)s - %(message)s',
    handlers=[
        logging.FileHandler('/var/log/mavlink/heartbeat_monitor.log'),
        logging.StreamHandler()
    ]
)
logger = logging.getLogger(__name__)

class HeartbeatMonitor:
    def __init__(self, udp_port=14560, timeout_seconds=30, service_name="mavlink-router"):
        self.udp_port = udp_port
        self.timeout_seconds = timeout_seconds
        self.service_name = service_name
        self.last_heartbeat = None
        self.sock = None
        
    def setup_socket(self):
        """Setup UDP socket to listen for MAVLink messages"""
        try:
            self.sock = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
            self.sock.bind(('127.0.0.1', self.udp_port + 1))  # Use different port to avoid conflicts
            self.sock.settimeout(1.0)  # 1 second timeout for socket operations
            logger.info(f"Listening for heartbeat on UDP port {self.udp_port + 1}")
            return True
        except Exception as e:
            logger.error(f"Failed to setup socket: {e}")
            return False
            
    def check_heartbeat_via_udp(self):
        """Check for MAVLink heartbeat messages via UDP"""
        try:
            # Connect to the MAVProxy UDP output
            client_sock = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
            client_sock.settimeout(5.0)
            
            # Send a request to trigger heartbeat response
            client_sock.sendto(b'\xfe\x09\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x04\x05', 
                             ('127.0.0.1', self.udp_port))
            
            # Try to receive heartbeat
            data, addr = client_sock.recvfrom(1024)
            client_sock.close()
            
            if data and len(data) > 5:
                # Basic MAVLink packet validation
                if data[0] == 0xfe or data[0] == 0xfd:  # MAVLink v1 or v2 magic number
                    self.last_heartbeat = datetime.now()
                    return True
                    
        except socket.timeout:
            pass
        except Exception as e:
            logger.debug(f"UDP heartbeat check failed: {e}")
            
        return False
        
    def check_service_status(self):
        """Check if the MAVLink service is running"""
        try:
            result = subprocess.run(
                ['systemctl', 'is-active', self.service_name],
                capture_output=True,
                text=True,
                timeout=10
            )
            return result.stdout.strip() == 'active'
        except Exception as e:
            logger.error(f"Failed to check service status: {e}")
            return False
            
    def restart_service(self):
        """Restart the MAVLink service"""
        try:
            logger.warning(f"Restarting {self.service_name} due to heartbeat timeout")
            result = subprocess.run(
                ['sudo', 'systemctl', 'restart', self.service_name],
                capture_output=True,
                text=True,
                timeout=30
            )
            
            if result.returncode == 0:
                logger.info(f"Successfully restarted {self.service_name}")
                self.last_heartbeat = None  # Reset heartbeat tracking
                return True
            else:
                logger.error(f"Failed to restart service: {result.stderr}")
                return False
                
        except Exception as e:
            logger.error(f"Exception during service restart: {e}")
            return False
            
    def run(self):
        """Main monitoring loop"""
        logger.info("Starting MAVLink heartbeat monitor")
        
        while True:
            try:
                # Check if service is running
                if not self.check_service_status():
                    logger.warning(f"Service {self.service_name} is not active")
                    time.sleep(10)
                    continue
                
                # Check for heartbeat
                if self.check_heartbeat_via_udp():
                    logger.debug("Heartbeat detected")
                
                # Check if we've lost heartbeat for too long
                if self.last_heartbeat:
                    time_since_heartbeat = datetime.now() - self.last_heartbeat
                    if time_since_heartbeat.total_seconds() > self.timeout_seconds:
                        logger.warning(f"No heartbeat for {time_since_heartbeat.total_seconds():.1f} seconds")
                        self.restart_service()
                        time.sleep(30)  # Wait before resuming monitoring
                
                time.sleep(5)  # Check every 5 seconds
                
            except KeyboardInterrupt:
                logger.info("Heartbeat monitor stopped by user")
                break
            except Exception as e:
                logger.error(f"Unexpected error in monitoring loop: {e}")
                time.sleep(10)
                
        if self.sock:
            self.sock.close()

def main():
    # Load configuration
    config_file = "/opt/mavlink/config.env"
    internal_port = 14560  # Default
    
    if os.path.exists(config_file):
        with open(config_file, 'r') as f:
            for line in f:
                line = line.strip()
                if line.startswith('INTERNAL_PORT='):
                    internal_port = int(line.split('=')[1])
                    
    monitor = HeartbeatMonitor(udp_port=internal_port)
    monitor.run()

if __name__ == "__main__":
    main()
