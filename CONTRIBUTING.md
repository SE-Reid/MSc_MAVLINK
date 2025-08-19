# Contributing to MSc_MAVLINKRouting

Thank you for your interest in contributing to MSc_MAVLINKRouting! This document provides guidelines for contributing to the project.

## Code of Conduct

This project follows a simple code of conduct: be respectful, be constructive, and help make this project better for everyone.

## How to Contribute

### Reporting Issues

1. **Check existing issues** first to avoid duplicates
2. **Use clear, descriptive titles** for bug reports and feature requests
3. **Provide detailed information**:
   - Steps to reproduce (for bugs)
   - Expected vs actual behavior
   - System information (OS, Python version, etc.)
   - Relevant log outputs

### Submitting Changes

1. **Fork the repository** and create a feature branch
2. **Make your changes** with clear, focused commits
3. **Test your changes** thoroughly
4. **Update documentation** if needed
5. **Submit a pull request** with a clear description

### Development Setup

1. Clone the repository:
   ```bash
   git clone https://github.com/your-username/MSc_MAVLINKRouting.git
   cd MSc_MAVLINKRouting
   ```

2. Test the deployment script:
   ```bash
   ./scripts/deploy.sh
   ```

3. For testing on actual hardware, copy to a Raspberry Pi and run:
   ```bash
   sudo ./install.sh
   ```

### Code Style

- **Shell scripts**: Follow standard bash conventions
- **Python code**: Follow PEP 8 guidelines
- **Comments**: Write clear, helpful comments
- **Error handling**: Include appropriate error checking

### Testing

- Test installation on clean Raspberry Pi systems
- Verify systemd services start and run correctly
- Test heartbeat monitoring functionality
- Check log outputs for errors

### Documentation

- Update README.md for user-facing changes
- Update CHANGELOG.md following [Keep a Changelog](https://keepachangelog.com/)
- Add or update comments in code as needed

## Project Structure

```
MSc_MAVLINKRouting/
├── src/                    # Runtime source files
├── systemd/               # Service definitions
├── scripts/               # Development tools
├── docs/                  # Documentation
└── install.sh            # Main installer
```

## Questions?

If you have questions about contributing, feel free to:
- Open an issue for discussion
- Start a conversation in pull requests
- Reach out to maintainers

Thank you for helping make MSc_MAVLINKRouting better!
