# frozen_string_literal: true

require 'yaml'
require 'json'
require 'faraday'
require 'ruby_llm'

require_relative 'mcp_agent/version'
require_relative 'mcp_agent/base/error_handler'
require_relative 'mcp_agent/base/mcp_client'
require_relative 'mcp_agent/base/transport'
require_relative 'mcp_agent/credentials'
require_relative 'mcp_agent/generator'
require_relative 'mcp_agent/base/agent'
require_relative 'mcp_agent/transports/telegram'
require_relative 'mcp_agent/transports/rabbitmq'

# ==============================================================================
# McpAgent - Универсальная платформа для создания интеллектуальных агентов
# ==============================================================================
# 
# Позволяет создавать агентов с:
# - Динамическим подключением к любому MCP серверу
# - Поддержкой транспортов (Telegram, RabbitMQ)
# - AI обработкой через OpenAI
# - Безопасным хранением credentials (AES-256-GCM)
#
# Пример использования:
#
#   agent = McpAgent::Agent.new(config_path: 'config/settings.yml')
#   agent.setup_transports
#   agent.run
#
module McpAgent
end
