# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

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
- AI processing with OpenAI (GPT-4.1-mini by default)
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

