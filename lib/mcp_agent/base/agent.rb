# frozen_string_literal: true

require 'yaml'
require 'ruby_llm'

module McpAgent
  # ==============================================================================
  # Agent - Универсальный агент с поддержкой транспортов
  # ==============================================================================
  # Реализует стандартную логику обработки запросов:
  # 1. Загрузка данных из ВСЕХ доступных MCP инструментов
  # 2. Формирование контекста для AI
  # 3. Обработка запроса через AI с system prompt из конфига
  # 
  # Все агенты имеют доступ ко всем инструментам MCP сервера по умолчанию.
  # Вся конфигурация (промпт) определяется в settings.yml
  # ==============================================================================
  class Agent
    attr_reader :config, :credentials, :mcp_client, :chat, :name, :version, :transports

    def initialize(config_path: 'config/settings.yml')
      @transports = []
      @running = false
      
      load_configuration(config_path)
      load_credentials_from_paths
      setup_logging
      setup_mcp_client
      setup_ai_client
      load_processing_config
    end

    # Обработка запроса с использованием AI и данных из MCP
    def process_query(query)
      all_tools = @mcp_client.available_tools
      context = load_context(all_tools)
      ai_response = process_with_ai(query, context, @system_prompt)
      format_response(ai_response)
    rescue => e
      ErrorHandler.handle_error(e, { component: 'agent', operation: 'process_query' })
      { content: [{ type: 'text', text: "Извините, произошла ошибка: #{e.message}" }], isError: true }
    end

    # ==============================================================================
    # Управление транспортами
    # ==============================================================================

    # Автоматическая инициализация всех транспортов
    # Все транспорты включены по умолчанию
    def setup_transports
      # Telegram транспорт
      setup_telegram_transport

      # RabbitMQ транспорт
      setup_rabbitmq_transport
    end

    # Запуск всех транспортов
    def start
      @transports.each(&:start)
      @running = true
      setup_signal_handlers
    end

    # Остановка всех транспортов
    def stop
      @transports.each(&:stop)
      @running = false

      ErrorHandler.log(:info, "Агент завершает работу", {
        component: 'agent',
        operation: 'stop'
      })
    end

    # Держать процесс активным
    def run
      start
      sleep
    end

    protected

    def load_configuration(config_path)
      @config = YAML.load_file(config_path)
      
      # Обязательные параметры
      @name = @config.dig('agent', 'name')
      unless @name
        raise ErrorHandler::ConfigurationError, "Missing required parameter: agent.name in #{config_path}"
      end
      
      # Опциональные параметры с дефолтами
      @version = @config.dig('agent', 'version') || '1.0.0'
    rescue Errno::ENOENT => e
      raise ErrorHandler::ConfigurationError, "Configuration file not found: #{config_path}"
    rescue => e
      raise ErrorHandler::ConfigurationError, "Failed to load configuration: #{e.message}"
    end

    def load_credentials_from_paths
      # Ожидаем, что credentials будут переданы в конфиге уже расшифрованными
      # Rails приложение должно расшифровать credentials и передать их в config/settings.yml
      # Или через переменные окружения
      
      credentials_config = @config['credentials'] || {}
      
      # Проверяем, переданы ли credentials напрямую в конфиге
      if credentials_config.is_a?(Hash) && credentials_config.key?('openai_api_key')
        # Credentials переданы напрямую в конфиге (уже расшифрованные Rails приложением)
        @credentials = credentials_config.transform_keys(&:to_sym)
      else
        # Иначе используем переменные окружения
        @credentials = {
          openai_api_key: ENV['OPENAI_API_KEY'],
          mcp_auth_token: ENV['MCP_AUTH_TOKEN'],
          telegram_token: ENV['TELEGRAM_TOKEN'],
          rabbitmq_username: ENV['RABBITMQ_USERNAME'],
          rabbitmq_password: ENV['RABBITMQ_PASSWORD']
        }
      end
      
      ErrorHandler.log(:info, "✅ Credentials загружены", {
        component: 'agent',
        operation: 'load_credentials'
      })
    rescue => e
      raise ErrorHandler::ConfigurationError, "Failed to load credentials: #{e.message}"
    end

    def setup_logging
      log_level_str = @config.dig('agent', 'log_level') || 'INFO'
      log_level = Logger.const_get(log_level_str.upcase) rescue Logger::INFO
      ErrorHandler.setup_logger(log_level: log_level)
    end

    def setup_mcp_client
      mcp_url = @config.dig('mcp', 'url')
      auth_token = @credentials[:mcp_auth_token]
      
      unless mcp_url
        raise ErrorHandler::ConfigurationError, "Missing required parameter: mcp.url in config/settings.yml"
      end
      
      unless auth_token
        raise ErrorHandler::ConfigurationError, "Missing required credential: mcp_auth_token in credentials"
      end

      @mcp_client = McpClient.new(mcp_url, auth_token)
    end

    def setup_ai_client
      openai_api_key = @credentials[:openai_api_key]
      
      unless openai_api_key
        raise ErrorHandler::ConfigurationError, "Missing openai_api_key in credentials"
      end

      RubyLLM.configure do |config|
        config.openai_api_key = openai_api_key
      end

      # Модель из конфига или дефолтная gpt-4.1-mini
      ai_model = @config.dig('ai', 'model') || 'gpt-4.1-mini'
      @chat = RubyLLM.chat(model: ai_model)
      
      ErrorHandler.log(:info, "🤖 AI клиент инициализирован с моделью #{ai_model}", {
        component: 'agent',
        operation: 'setup_ai_client'
      })
    end

    # Форматирование ответа для MCP
    def format_response(text)
      { content: [{ type: 'text', text: text.to_s }] }
    end

    # Обработка с помощью AI
    def process_with_ai(query, context, system_prompt)
      user_prompt = "Запрос: #{query}\n\nИнформация:\n#{context}\n\nОтветь на запрос."

      @chat.with_instructions(system_prompt)
      response = @chat.ask(user_prompt)
      
      if response&.content
        ErrorHandler.log(:info, "🤖 ИИ обработка завершена", {
          component: 'agent',
          operation: 'ai_processing',
          metadata: { tokens: response.output_tokens }
        })
        response.content
      else
        raise ErrorHandler::AIProcessingError, "Empty AI response"
      end
    end

    private

    def setup_telegram_transport
      token = @credentials[:telegram_token]
      
      if token && !token.empty?
        telegram_transport = TelegramTransport.new(self, token: token)
        @transports << telegram_transport
      else
        ErrorHandler.log(:warn, "Telegram транспорт включен, но токен не найден", {
          component: 'agent',
          operation: 'setup_telegram_transport'
        })
      end
    end

    def setup_rabbitmq_transport
      config = @config.dig('transports', 'rabbitmq') || {}
      
      rabbitmq_config = {
        host: config['host'] || ENV['RABBITMQ_HOST'] || 'localhost',
        port: config['port'] || ENV['RABBITMQ_PORT']&.to_i || 5672,
        username: @credentials[:rabbitmq_username] || ENV['RABBITMQ_USERNAME'] || 'guest',
        password: @credentials[:rabbitmq_password] || ENV['RABBITMQ_PASSWORD'] || 'guest',
        vhost: config['vhost'] || ENV['RABBITMQ_VHOST'] || '/',
        exchange: config['exchange'] || 'mcp_agents',
        queue: config['queue'] || "#{@name}_queue",
        routing_key: config['routing_key'] || @name
      }
      
      rabbitmq_transport = RabbitMQTransport.new(self, rabbitmq_config)
      @transports << rabbitmq_transport
    rescue => e
      ErrorHandler.log(:error, "Ошибка инициализации RabbitMQ: #{e.message}", {
        component: 'agent',
        operation: 'setup_rabbitmq_transport'
      })
    end

    def setup_signal_handlers
      Signal.trap("TERM") { stop; exit 0 }
      Signal.trap("INT") { stop; exit 0 }
      
      at_exit do
        stop unless !@running
      end
    end

    # ==============================================================================
    # Логика обработки запросов
    # ==============================================================================

    def load_processing_config
      processing_config = @config['processing']
      
      unless processing_config
        raise ErrorHandler::ConfigurationError, "Missing required section: processing in config/settings.yml"
      end
      
      # Загружаем system prompt из конфига (обязательный параметр)
      @system_prompt = processing_config['system_prompt']
      
      unless @system_prompt
        raise ErrorHandler::ConfigurationError, "Missing required parameter: processing.system_prompt in config/settings.yml"
      end
      
      ErrorHandler.log(:info, "🤖 Агент инициализирован с доступом ко всем MCP инструментам", {
        component: 'agent',
        operation: 'load_processing_config'
      })
    end

    def load_context(tools)
      ErrorHandler.log(:info, "📦 Загрузка данных из всех доступных инструментов", {
        component: 'agent',
        operation: 'load_context',
        metadata: { tools_count: tools.size }
      })
      
      tools.map do |tool_name|
        if @mcp_client.respond_to?(tool_name)
          data = @mcp_client.send(tool_name)
          "=== #{tool_name.upcase} ===\n\n#{data}"
        else
          nil
        end
      rescue => e
        ErrorHandler.log(:warn, "Не удалось загрузить #{tool_name}: #{e.message}", {
          component: 'agent',
          operation: 'load_context'
        })
        nil
      end.compact.join("\n\n")
    end
  end
end

