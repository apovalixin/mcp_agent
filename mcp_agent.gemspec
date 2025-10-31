# frozen_string_literal: true

require_relative 'lib/mcp_agent/version'

Gem::Specification.new do |spec|
  spec.name          = 'mcp_agent'
  spec.version       = McpAgent::VERSION
  spec.authors       = ['']
  spec.email         = ['']

  spec.summary       = 'Универсальная платформа для создания интеллектуальных агентов с MCP'
  spec.description   = <<~DESC
    McpAgent - это универсальная платформа для быстрого создания интеллектуальных агентов.
    
    Особенности:
    - Динамическое подключение к любому MCP серверу
    - Поддержка транспортов: Telegram Bot, RabbitMQ
    - AI обработка через OpenAI
    - Гибкая конфигурация через YAML файлы
    - Модульная архитектура с переиспользуемыми компонентами
    
    Создание агента занимает всего 5 минут!
  DESC
  
  spec.homepage      = 'https://github.com/apovalixin/mcp_agent'
  spec.license       = 'MIT'
  spec.required_ruby_version = '> 3.4'

  spec.metadata['homepage_uri'] = spec.homepage
  spec.metadata['source_code_uri'] = spec.homepage
  spec.metadata['changelog_uri'] = "#{spec.homepage}/blob/main/CHANGELOG.md"
  spec.metadata['bug_tracker_uri'] = "#{spec.homepage}/issues"
  spec.metadata['documentation_uri'] = "#{spec.homepage}/blob/main/README.md"

  # Указываем файлы для включения в gem
  spec.files = Dir.glob('{lib,exe,templates}/**/*') + %w[README.md LICENSE.txt CHANGELOG.md]
  spec.bindir = 'exe'
  spec.executables = ['mcp_agent']
  spec.require_paths = ['lib']

  # Основные зависимости
  spec.add_dependency 'faraday', '~> 2.14'      # HTTP клиент для MCP
  spec.add_dependency 'ruby_llm', '~> 1.8'      # AI обработка (OpenAI)
  
  # Транспорты
  spec.add_dependency 'telegram-bot', '~> 0.16' # Telegram Bot API
  spec.add_dependency 'bunny', '~> 2.24'        # RabbitMQ клиент
  
  # Credentials шифрование
  spec.add_dependency 'activesupport', '~> 8.0' # Encrypted credentials
  
  # Утилиты
  spec.add_dependency 'json', '~> 2.12'
  spec.add_dependency 'yaml', '~> 0.4'
  
  # Development зависимости
  spec.add_development_dependency 'rake', '~> 13.0'
  spec.add_development_dependency 'rspec', '~> 3.0'
end
