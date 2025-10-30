# frozen_string_literal: true

require 'active_support'
require 'active_support/encrypted_configuration'
require 'fileutils'

module McpAgent
  # ==============================================================================
  # Credentials - Управление зашифрованными credentials в Rails-стиле
  # ==============================================================================
  # Использует ActiveSupport::EncryptedConfiguration для безопасного хранения
  # секретов (API ключи, токены) в зашифрованном файле credentials.yml.enc
  #
  # Использование:
  #   McpAgent::Credentials.edit     # Редактировать credentials
  #   McpAgent::Credentials.show     # Показать текущие credentials
  #   McpAgent::Credentials.read     # Прочитать credentials как Hash
  #
  # Файлы:
  #   config/credentials.yml.enc  - зашифрованный файл с credentials
  #   config/master.key           - ключ шифрования (НЕ коммитить!)
  # ==============================================================================
  module Credentials
    class << self
      # Редактировать credentials в текстовом редакторе
      def edit
        # Отключаем RUBYOPT чтобы избежать конфликтов
        ENV.delete('RUBYOPT')
        
        ensure_config_directory
        ensure_master_key
        
        credentials_config = open_credentials
        
        # Создаём шаблон если файл новый
        unless File.exist?('config/credentials.yml.enc')
          credentials_config.write(default_template)
          puts "✅ Создан новый файл credentials с шаблоном"
        end
        
        puts "\n📝 Открываю редактор credentials..."
        puts "Редактируйте файл, сохраните и закройте редактор\n\n"
        
        credentials_config.change do |tmp_path|
          system("${EDITOR:-nano} #{tmp_path}")
        end
        
        puts "\n✅ Credentials сохранены!"
        puts "📄 Файл: config/credentials.yml.enc"
        
      rescue => e
        ErrorHandler.log(:error, "Ошибка редактирования credentials: #{e.message}", {
          component: 'credentials',
          operation: 'edit'
        })
        raise
      end
      
      # Показать текущие credentials в консоли
      def show
        ensure_config_directory
        
        unless File.exist?('config/credentials.yml.enc')
          puts "❌ Файл credentials.yml.enc не найден"
          puts "   Запустите credentials_edit.rb для создания"
          return
        end
        
        credentials_config = open_credentials
        content = credentials_config.read
        
        puts "\n" + "="*60
        puts "📄 Текущие credentials (config/credentials.yml.enc):"
        puts "="*60
        puts content
        puts "="*60 + "\n"
        
      rescue => e
        puts "❌ Ошибка чтения credentials: #{e.message}"
        puts "   Проверьте наличие config/master.key"
      end
      
      # Прочитать credentials как Hash (для использования в коде)
      def read
        ensure_config_directory
        
        unless File.exist?('config/credentials.yml.enc')
          raise ConfigurationError, "Credentials file not found. Run credentials_edit.rb first."
        end
        
        credentials_config = open_credentials
        content = credentials_config.read
        
        require 'yaml'
        YAML.safe_load(content, permitted_classes: [Symbol], symbolize_names: true) || {}
        
      rescue => e
        ErrorHandler.log(:error, "Ошибка чтения credentials: #{e.message}", {
          component: 'credentials',
          operation: 'read'
        })
        raise ConfigurationError, "Failed to read credentials: #{e.message}"
      end
      
      private
      
      def ensure_config_directory
        FileUtils.mkdir_p('config')
      end
      
      def ensure_master_key
        master_key_path = 'config/master.key'
        
        if File.exist?(master_key_path)
          # Проверяем длину существующего ключа
          existing_key = File.read(master_key_path).strip
          if existing_key.length != 32
            puts "⚠️  Существующий master.key имеет неправильную длину (#{existing_key.length})"
            puts "   Создаём новый ключ..."
            create_new_key(master_key_path)
          end
        else
          create_new_key(master_key_path)
        end
      end
      
      def create_new_key(master_key_path)
        require 'securerandom'
        key = SecureRandom.alphanumeric(32)  # Ровно 32 символа
        File.write(master_key_path, key)
        File.chmod(0600, master_key_path)
        puts "✅ Создан новый master key: #{master_key_path}"
        puts "⚠️  ВАЖНО: НЕ КОММИТЬТЕ этот файл в git!"
        puts "⚠️  Добавьте config/master.key в .gitignore"
      end
      
      def open_credentials
        ActiveSupport::EncryptedConfiguration.new(
          config_path: 'config/credentials.yml.enc',
          key_path: 'config/master.key',
          env_key: 'MASTER_KEY',
          raise_if_missing_key: true
        )
      end
      
      def default_template
        <<~YAML
          # ==============================================================================
          # Зашифрованные credentials для агента
          # ==============================================================================
          # Этот файл зашифрован с помощью config/master.key
          # Редактирование: ./credentials_edit.rb
          # Просмотр: ./credentials_show.rb
          # ==============================================================================
          
          # OpenAI API Key (обязательно)
          openai_api_key: sk-your-key-here
          
          # MCP Server Authentication Token (обязательно)
          mcp_auth_token: Bearer your-token-here
          
          # Telegram Bot Token (опционально, для Telegram транспорта)
          # Получить можно у @BotFather в Telegram
          telegram_token: 123456789:ABCdefGHIjklMNOpqrsTUVwxyz
          
          # RabbitMQ credentials (опционально, для RabbitMQ транспорта)
          rabbitmq_username: guest
          rabbitmq_password: guest
        YAML
      end
    end
  end
end

