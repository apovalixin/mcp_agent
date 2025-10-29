# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [1.1.0] - 2025-10-29

### Changed
- **BREAKING**: Removed built-in credentials encryption from gem
  - Credentials management now delegated to Rails applications or external scripts
  - Gem expects already decrypted credentials via config or ENV variables
  
### Removed
- Removed `McpAgent::Credentials` class
- Removed `credentials_edit.rb` and `credentials_show.rb` scripts
- Removed dependency on internal credentials encryption

### Added
- New flexible credentials loading mechanism:
  - Support for passing decrypted credentials directly in `config/settings.yml`
  - Automatic fallback to environment variables
- Comprehensive Rails integration guide
  - Example rake task for generating config with decrypted credentials
  - Best practices for using Rails encrypted credentials

### Improved
- Better separation of concerns - gem focuses on agent logic, not credentials management
- Simplified deployment with standard ENV variable support
- Enhanced documentation with Rails integration examples

## [1.0.1] - 2025-10-29

### Fixed
- Fixed RUBYOPT environment variable conflict in Credentials.edit and Credentials.show methods
  - Added automatic cleanup of RUBYOPT to prevent "invalid switch in RUBYOPT" errors

  - Credentials now accessible via convenient scripts: `./credentials_edit.rb` and `./credentials_show.rb`

### Changed
- Added executable scripts for credentials management
- Updated all documentation to reflect new naming

## [1.0.0] - 2025-01-29

### Added
- Initial release of McpAgent gem
- Universal agent framework with MCP server support
- Dynamic tool loading from any MCP server
- Transport layer: Telegram Bot and RabbitMQ
- AI processing with OpenAI
- Secure credentials management with AES-256-GCM encryption
- Modular architecture with reusable components
- Comprehensive error handling and logging
- Configuration through YAML files
- Support for multiple concurrent transports

### Features
- **Agent Base**: Core agent functionality with customizable system prompts
- **MCP Client**: Dynamic connection to any MCP-compatible server
- **Transports**: 
  - Telegram Bot with markdown support
  - RabbitMQ for inter-agent communication (framework ready)
- **Credentials**: Rails-like encrypted credentials system
- **AI Integration**: OpenAI integration with configurable models
- **Error Handling**: Centralized error handling with structured logging

### Documentation
- Complete README with quick start guide
- Example configurations
- API documentation in code comments

