# Changelog

All notable changes to the Wander Zero-to-Running Developer Environment will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added
- Comprehensive documentation suite
- GitHub Actions CI/CD workflow
- Performance benchmarking script
- Smoke test script
- Operations guide with complete command reference

## [1.0.0] - 2025-11-12

### Added
- **Phase 1: Core MVP**
  - Docker Compose setup for all services
  - Frontend (React + TypeScript + Tailwind CSS)
  - Backend API (Node.js + Express + TypeScript)
  - PostgreSQL database
  - Redis cache
  - Basic health checks
  - Makefile for common operations

- **Phase 2: Enhanced Experience**
  - Service orchestration with health checks
  - Enhanced logging with colored output
  - Error handling and recovery
  - Status and monitoring commands
  - Resource usage monitoring

- **Phase 3: Advanced Features**
  - Environment profiles (minimal, backend, full)
  - Database seeding system
  - Pre-commit hooks (Husky + ESLint + Prettier)
  - Migration creation helper

- **Phase 4: Developer Quality of Life**
  - Individual service control (start/stop/restart)
  - Database management (backup, restore, snapshot)
  - Snapshot & restore system with git tracking
  - Dashboard API endpoint
  - Test command framework

- **Phase 5: Polish & Production Ready**
  - Comprehensive documentation
  - Quick start guide
  - Troubleshooting guide
  - FAQ
  - Architecture documentation
  - Developer guide
  - Operations guide
  - Known issues tracking
  - CI/CD workflow
  - Performance benchmarking
  - Smoke tests

### Changed
- Improved Windows compatibility for Makefile commands
- Enhanced error messages and user feedback
- Better cross-platform support

### Fixed
- Docker Compose version warning
- npm ci without package-lock.json
- Cross-platform date commands
- Windows path handling issues

## [0.1.0] - 2025-11-12

### Added
- Initial project structure
- Planning documents
- Git repository setup

---

## Version History

- **1.0.0** - First stable release with all core features
- **0.1.0** - Initial planning and setup

