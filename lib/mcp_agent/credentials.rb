# frozen_string_literal: true

require 'openssl'
require 'yaml'
require 'base64'
require 'tempfile'
require 'securerandom'
require 'json'

module McpAgent
  # ==============================================================================
  # Credentials - Система шифрования credentials (аналог Rails credentials)
  # ==============================================================================
  class Credentials
    CREDENTIALS_PATH = 'config/credentials.yml.enc'
    KEY_PATH = 'config/master.key'

    class << self
      # Загрузка credentials
      def load
        master_key = read_master_key
        encrypted_content = File.read(CREDENTIALS_PATH)
        decrypted_content = decrypt(encrypted_content, master_key)
        YAML.safe_load(decrypted_content, symbolize_names: true)
      rescue Errno::ENOENT => e
        if e.message.include?('master.key')
          raise "Master key not found. Set MASTER_KEY environment variable or create config/master.key"
        elsif e.message.include?('credentials.yml.enc')
          raise "Credentials file not found. Run: ./credentials_edit.rb"
        else
          raise
        end
      rescue => e
        raise "Failed to load credentials: #{e.message}"
      end

      # Редактирование credentials (открывает редактор)
      def edit
        # Очищаем проблемную переменную окружения RUBYOPT
        # Это необходимо для корректной работы при вызове через bundle exec ruby
        ENV.delete('RUBYOPT')
        
        master_key = read_or_create_master_key
        
        # Читаем существующий файл или создаем пустой
        begin
          encrypted_content = File.read(CREDENTIALS_PATH)
          content = decrypt(encrypted_content, master_key)
        rescue Errno::ENOENT
          content = default_credentials_template
        end

        # Создаем временный файл для редактирования
        temp_file = Tempfile.new(['credentials', '.yml'])
        temp_file.write(content)
        temp_file.close

        # Открываем редактор
        editor = ENV['EDITOR'] || 'nano'
        system("#{editor} #{temp_file.path}")

        # Читаем отредактированное содержимое
        edited_content = File.read(temp_file.path)
        
        # Валидируем YAML
        YAML.safe_load(edited_content)
        
        # Шифруем и сохраняем
        encrypted = encrypt(edited_content, master_key)
        File.write(CREDENTIALS_PATH, encrypted)
        
        puts "✅ Credentials сохранены в #{CREDENTIALS_PATH}"
        puts "🔑 Master key: #{master_key}" unless File.exist?(KEY_PATH)
      rescue => e
        puts "❌ Ошибка при редактировании credentials: #{e.message}"
        raise
      ensure
        temp_file.unlink if temp_file
      end

      # Показать расшифрованные credentials
      def show
        # Очищаем проблемную переменную окружения RUBYOPT
        # Это необходимо для корректной работы при вызове через bundle exec ruby
        ENV.delete('RUBYOPT')
        
        master_key = read_master_key
        encrypted_content = File.read(CREDENTIALS_PATH)
        decrypted_content = decrypt(encrypted_content, master_key)
        puts decrypted_content
      rescue => e
        puts "❌ Ошибка: #{e.message}"
        raise
      end

      # Создание нового credentials файла из YAML строки
      def create(yaml_content)
        master_key = read_or_create_master_key
        
        # Валидируем YAML
        YAML.safe_load(yaml_content)
        
        # Шифруем и сохраняем
        encrypted = encrypt(yaml_content, master_key)
        File.write(CREDENTIALS_PATH, encrypted)
        
        puts "✅ Credentials созданы в #{CREDENTIALS_PATH}"
      rescue => e
        puts "❌ Ошибка при создании credentials: #{e.message}"
        raise
      end

      private

      # Чтение master key
      def read_master_key
        # Сначала проверяем переменную окружения
        key = ENV['MASTER_KEY']
        return key if key && !key.empty?

        # Затем проверяем файл
        if File.exist?(KEY_PATH)
          File.read(KEY_PATH).strip
        else
          raise "Master key not found. Set MASTER_KEY environment variable or create #{KEY_PATH}"
        end
      end

      # Чтение или создание master key
      def read_or_create_master_key
        read_master_key
      rescue
        # Создаем новый ключ
        new_key = generate_key
        
        # Создаем директорию config если её нет
        Dir.mkdir('config') unless Dir.exist?('config')
        
        File.write(KEY_PATH, new_key)
        File.chmod(0600, KEY_PATH) # Ограничиваем права доступа
        
        puts "🔑 Создан новый master key: #{new_key}"
        puts "   Сохранен в #{KEY_PATH}"
        puts "   Или добавьте в .env: MASTER_KEY=#{new_key}"
        
        new_key
      end

      # Генерация нового ключа
      def generate_key
        SecureRandom.hex(32)
      end

      # Шифрование AES-256-GCM
      def encrypt(data, key)
        cipher = OpenSSL::Cipher.new('aes-256-gcm')
        cipher.encrypt
        cipher.key = [key].pack('H*') # Преобразуем hex в binary
        
        iv = cipher.random_iv
        cipher.auth_data = ''
        
        encrypted = cipher.update(data) + cipher.final
        auth_tag = cipher.auth_tag
        
        # Возвращаем: iv + auth_tag + encrypted_data (все в base64)
        result = {
          iv: Base64.strict_encode64(iv),
          auth_tag: Base64.strict_encode64(auth_tag),
          data: Base64.strict_encode64(encrypted)
        }
        
        Base64.strict_encode64(result.to_json)
      end

      # Расшифрование AES-256-GCM
      def decrypt(encrypted_data, key)
        # Декодируем из base64
        json_data = Base64.strict_decode64(encrypted_data)
        data = JSON.parse(json_data)
        
        iv = Base64.strict_decode64(data['iv'])
        auth_tag = Base64.strict_decode64(data['auth_tag'])
        encrypted = Base64.strict_decode64(data['data'])
        
        decipher = OpenSSL::Cipher.new('aes-256-gcm')
        decipher.decrypt
        decipher.key = [key].pack('H*')
        decipher.iv = iv
        decipher.auth_tag = auth_tag
        decipher.auth_data = ''
        
        decipher.update(encrypted) + decipher.final
      end

      # Шаблон по умолчанию для credentials (без привязки к конкретному сайту)
      def default_credentials_template
        <<~YAML
          # OpenAI API Key
          openai_api_key: sk-your-key-here
          
          # MCP Authentication Token (для вашего MCP сервера)
          mcp_auth_token: Bearer your-token-here
          
          # Telegram Bot Token (опционально)
          telegram_token: 123456789:ABCdefGHIjklMNOpqrsTUVwxyz
          
          # RabbitMQ credentials (опционально)
          # rabbitmq_username: guest
          # rabbitmq_password: guest
        YAML
      end
    end
  end
end

