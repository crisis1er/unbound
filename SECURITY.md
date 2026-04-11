# Security Policy

## Supported Versions

| Version | Supported |
|---------|-----------|
| 2.x     | ✅ Yes    |
| 1.x     | ❌ No     |

## Reporting a Vulnerability

Do **not** open a public GitHub issue for security vulnerabilities.

Please report security issues privately to:

📧 **safeitexperts@safeitexperts.com**

Include:
- Description of the vulnerability
- Steps to reproduce
- Potential impact
- Your openSUSE / Unbound version

We will acknowledge receipt within **72 hours** and aim to release a fix
within **14 days** for critical issues.

## Security Hardening Notes

This configuration is designed for use with:
- openSUSE Tumbleweed
- SELinux enforcing mode
- Firewalld active
- DNSSEC validation enabled

Always review the configuration before deployment in production.
