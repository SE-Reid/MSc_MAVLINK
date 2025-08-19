# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added
- Initial release of MSc_MAVLINKRouting Service
- Automatic heartbeat monitoring with service restart
- Systemd service integration for auto-start on boot
- Device-specific configuration via environment files
- Robust error handling and logging
- Security features with dedicated user and minimal privileges
- Development deployment helper script
- Comprehensive documentation

### Features
- MAVProxy-based routing between serial and network interfaces
- TCP server for Ground Control Station connections
- UDP output for companion computer integration
- Virtual environment isolation for Python dependencies
- Configurable serial port, baud rate, and network ports
- Automatic service recovery on failure

## [1.0.0] - 2025-08-19

### Added
- Initial stable release
- Complete installation and deployment system
- Production-ready systemd services
- Monitoring and logging capabilities
