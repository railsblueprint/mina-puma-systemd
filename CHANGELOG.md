# Changelog

## [1.1.0] - 2025-01-19

### Added
- User validation to prevent generation of invalid systemd files
  - Validates that `puma_user` and `puma_group` are set before generating configs
  - Provides clear error messages with examples when validation fails
  - Applied to `puma:setup`, `puma:print`, and `puma:print_service` tasks
- Comprehensive test suite with RSpec
  - 8 tests covering all validation scenarios
  - Tests confirm invalid files would be generated without proper user config
- RSpec as development dependency

### Changed
- Updated README to highlight that `user` setting is required
- Added warning section about user configuration importance

### Fixed
- Prevents creation of systemd files with empty `User=` and `Group=` directives
- Users now get immediate, helpful error messages instead of cryptic systemd failures

## [1.0.3] - Previous releases
- Initial gem functionality
- Puma systemd service management
- Configuration templates