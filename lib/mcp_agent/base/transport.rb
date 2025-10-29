# frozen_string_literal: true

module McpAgent
  # ==============================================================================
  # Transport - Базовый абстрактный класс для транспортов
  # ==============================================================================
  class Transport
    attr_reader :agent, :config

    def initialize(agent, config = {})
      @agent = agent
      @config = config
      @running = false
    end

    # Запуск транспорта
    def start
      raise NotImplementedError, "#{self.class} must implement #start"
    end

    # Остановка транспорта
    def stop
      @running = false
    end

    # Отправка сообщения
    def send_message(recipient, message)
      raise NotImplementedError, "#{self.class} must implement #send_message"
    end

    # Получение сообщения (для polling-based транспортов)
    def receive_message
      raise NotImplementedError, "#{self.class} must implement #receive_message"
    end

    # Проверка, запущен ли транспорт
    def running?
      @running
    end

    protected

    # Обработка входящего сообщения через агента
    def process_message(message)
      @agent.process_query(message)
    end
  end
end

