#!/usr/bin/env ruby
# frozen_string_literal: true

# ==============================================================================
# Главный файл агента McpAgent
# ==============================================================================
# Автоматически создан с помощью: bundle exec mcp_agent init
# ==============================================================================

require 'bundler/setup'
require 'mcp_agent'

# Создание и запуск агента
agent = McpAgent::Agent.new(config_path: 'config/settings.yml')

puts ""
puts "🤖 #{agent.name} v#{agent.version}"
puts ""
puts "📡 Настройка транспортов для взаимодействия:"
puts ""

agent.setup_transports
puts ""

agent.run

