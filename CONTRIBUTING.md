# Contributing to unbound-tumbleweed-config

Thank you for your interest in contributing to this project.

## Prerequisites

- openSUSE Tumbleweed (rolling release)
- Unbound DNS resolver installed (`zypper in unbound`)
- Git configured with GPG signing enabled
- Basic knowledge of DNS, DNSSEC, and systemd

## How to Contribute

1. Fork the repository
2. Create a feature branch: `git checkout -b feat/your-feature`
3. Make your changes
4. Test your configuration: `unbound-checkconf unbound.conf`
5. Commit with Conventional Commits format:
   - `feat:`, `fix:`, `docs:`, `chore:`, `refactor:`
6. Push and open a Pull Request

## Style Guidelines

- Configuration files must be validated with `unbound-checkconf` before commit
- All changes must be documented in `CHANGELOG.md`
- Follow the existing file structure

## Reporting Issues

Open a GitHub issue with:
- Your openSUSE version (`cat /etc/os-release`)
- Unbound version (`unbound -V`)
- Relevant logs (`journalctl -u unbound`)

## Contact

safeitexperts@safeitexperts.com
