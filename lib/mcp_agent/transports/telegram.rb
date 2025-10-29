# frozen_string_literal: true

require 'telegram/bot'
require 'set'

module McpAgent
  # ==============================================================================
  # TelegramTransport - Транспорт для Telegram Bot
  # ==============================================================================
  class TelegramTransport < Transport
    TRANSPORT_NAME = '🤖 Telegram'
    
    def initialize(agent, config = {})
      super(agent, config)
      @token = config[:token]
      @processed_message_ids = Set.new
      
      raise ErrorHandler::ConfigurationError, "Telegram token not provided" unless @token
    end

    def start
      @running = true
      Thread.new do
        run_bot
      end
    end

    def stop
      super
      ErrorHandler.log(:info, "#{TRANSPORT_NAME}: Остановка транспорта", {
        component: 'telegram_transport',
        operation: 'shutdown'
      })
    end

    def send_message(chat_id, message)
      @bot.send_message(chat_id: chat_id, text: message, parse_mode: 'HTML')
    rescue => e
      ErrorHandler.log(:error, "#{TRANSPORT_NAME}: Ошибка отправки сообщения: #{e.message}", {
        component: 'telegram_transport',
        operation: 'send_message',
        metadata: { chat_id: chat_id }
      })
    end

    private

    def run_bot
      begin
        @bot = ::Telegram::Bot::Client.new(@token)
        bot_info = @bot.get_me
        puts "🤖 Telegram: @#{bot_info['result']['username']}"
      rescue ::Telegram::Bot::Error => e
        puts "❌ Telegram: неверный токен"
        return
      end

      offset = 0

      while @running
        begin
          response = @bot.get_updates(offset: offset, timeout: 30)
          
          response['result'].each do |update|
            next unless update['message']
            message = update['message']
            offset = update['update_id'] + 1
            
            message_id = message['message_id']
            next if @processed_message_ids.include?(message_id)
            
            @processed_message_ids.add(message_id)
            # Ограничиваем размер кэша
            @processed_message_ids = @processed_message_ids.to_a.last(100).to_set if @processed_message_ids.size > 100

            chat_id = message['chat']['id']

            handle_message(chat_id, message['text'])
          end
        rescue Interrupt
          break
        rescue => e
          ErrorHandler.log(:error, "#{TRANSPORT_NAME}: Ошибка в боте: #{e.message}", {
            component: 'telegram_transport',
            operation: 'main_loop'
          })
          sleep 5
        end
      end
    rescue => e
      ErrorHandler.log(:fatal, "#{TRANSPORT_NAME}: Критическая ошибка бота: #{e.message}", {
        component: 'telegram_transport',
        operation: 'thread'
      })
    ensure
      @running = false
    end

    def handle_message(chat_id, text)
      case text
      when '/start'
        send_message(chat_id, start_message)
      when '/help'
        send_message(chat_id, help_message)
      when /^[^\/]/
        @bot.send_chat_action(chat_id: chat_id, action: 'typing')
        
        begin
          start_time = Time.now
          
          puts "\n" + "Запрос через Telegram: #{text[0..100]}"
          puts "─" * 60
          ErrorHandler.log(:info, "#{TRANSPORT_NAME}: Получен запрос", {
            component: 'telegram_transport',
            operation: 'process_message',
            metadata: { 
              chat_id: chat_id,
              message_preview: text[0..50]
            }
          })
          puts ""
          
          response_data = process_message(text)
          
          response_text = response_data.dig(:content, 0, :text) ||
                         response_data.dig('content', 0, 'text') ||
                         "Не удалось сформировать ответ."

          processing_time = ((Time.now - start_time) * 1000).round

          puts ""
          ErrorHandler.log(:info, "#{TRANSPORT_NAME}: Запрос обработан успешно", {
            component: 'telegram_transport',
            operation: 'process_message',
            metadata: { 
              chat_id: chat_id,
              processing_time_ms: processing_time,
              response_length: response_text.length
            }
          })
          puts "─" * 60 + "\n"

          html_text = convert_markdown_to_telegram_html(response_text)
          send_message(chat_id, html_text)
        rescue => e
          ErrorHandler.handle_error(e, { 
            component: 'telegram_transport', 
            operation: 'process_message',
            metadata: { chat_id: chat_id }
          })
          send_message(chat_id, "❌ Произошла ошибка: #{e.message}")
        end
      end
    end

    def start_message
      <<~TEXT
        Привет! Я интеллектуальный помощник.
        
        Просто задай мне вопрос на русском языке!
      TEXT
    end

    def help_message
      "Задай любой вопрос!"
    end

    # Конвертация Markdown в Telegram HTML
    def convert_markdown_to_telegram_html(text)
      return text if text.nil? || text.empty?
      
      html = text.dup.gsub('&', '&amp;').gsub('<', '&lt;').gsub('>', '&gt;')
      html.gsub!(/```(.+?)```/m, '<pre>\1</pre>')
      html.gsub!(/^####? (.+)$/, '<b>\1</b>')
      html.gsub!(/^###? (.+)$/, '<b>\1</b>')
      html.gsub!(/^## (.+)$/, '<b>\1</b>')
      html.gsub!(/^# (.+)$/, '<b>\1</b>')
      html.gsub!(/\*\*(.+?)\*\*/, '<b>\1</b>')
      html.gsub!(/`(.+?)`/, '<code>\1</code>')
      html.gsub!(/(?<!\*)\*([^\*]+?)\*(?!\*)/, '<i>\1</i>')
      html.gsub!(/^  - (.+)$/, '    • \1')
      html.gsub!(/^- (.+)$/, '  • \1')
      html.gsub!(/\[(.+?)\]\((.+?)\)/, '<a href="\2">\1</a>')
      html
    end
  end
end

