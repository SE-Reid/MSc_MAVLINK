# Security Policy

## Supported Versions

We actively support the following versions with security updates:

| Version | Supported          |
| ------- | ------------------ |
| 1.0.x   | :white_check_mark: |

## Reporting a Vulnerability

If you discover a security vulnerability in MSc_MAVLINKRouting, please report it responsibly:

### How to Report

1. **Do NOT open a public issue** for security vulnerabilities
2. **Email the maintainers** with details (if email is available)
3. **Open a private issue** if the repository supports it
4. **Include the following information**:
   - Description of the vulnerability
   - Steps to reproduce
   - Potential impact
   - Suggested fix (if any)

### What to Expect

- **Acknowledgment** within 48 hours
- **Initial assessment** within 1 week
- **Regular updates** on progress
- **Credit** in security advisory (if desired)

### Security Considerations

MSc_MAVLINKRouting is designed with security in mind:

- **Dedicated user**: Runs as `mavlink` user with minimal privileges
- **System protection**: Uses systemd security features
- **File permissions**: Restricts access to configuration files
- **Network isolation**: Configurable network interfaces

### Common Security Best Practices

When deploying MSc_MAVLINKRouting:

1. **Keep system updated**: Regularly update your Raspberry Pi OS
2. **Firewall configuration**: Use `ufw` or `iptables` to restrict network access
3. **SSH security**: Use key-based authentication, disable password auth
4. **Regular monitoring**: Check logs for unusual activity
5. **Network segmentation**: Isolate drone networks from other systems

### Scope

This security policy covers:
- MSc_MAVLINKRouting source code
- Installation scripts
- Service configurations
- Documentation security guidance

It does not cover:
- Third-party dependencies (MAVProxy, Python packages)
- Operating system vulnerabilities
- Hardware security issues
- Network infrastructure security

Thank you for helping keep MSc_MAVLINKRouting secure!
