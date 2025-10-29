# frozen_string_literal: true

require 'logger'
require 'json'

module McpAgent
  # ==============================================================================
  # ErrorHandler - Централизованная система обработки ошибок
  # ==============================================================================
  module ErrorHandler
    class ConfigurationError < StandardError; end
    class NetworkError < StandardError; end
    class AIProcessingError < StandardError; end

    class << self
      attr_accessor :logger

      def setup_logger(log_level: Logger::INFO)
        @logger = Logger.new(STDOUT)
        @logger.level = log_level
        @logger.formatter = ->(severity, datetime, _progname, msg) do
          if msg.is_a?(String) && msg.start_with?('{')
            "#{msg}\n"
          else
            { timestamp: datetime.iso8601, level: severity, message: msg.to_s }.to_json + "\n"
          end
        end
      end

      def log(level, message, context = {})
        return unless @logger

        log_entry = {
          timestamp: Time.now.iso8601,
          level: level.to_s.upcase,
          message: message,
          component: context[:component] || 'unknown',
          operation: context[:operation],
          duration_ms: context[:duration_ms],
          metadata: context[:metadata] || {}
        }.compact

        @logger.send(level, log_entry.to_json)
      end

      def handle_error(error, context = {})
        log(:error, "Error: #{error.message}", {
          component: context[:component],
          operation: context[:operation],
          error_class: error.class.name,
          error_message: error.message
        })

        {
          error_message: error.message,
          retry_recommended: error.is_a?(NetworkError)
        }
      end
    end
  end
end

