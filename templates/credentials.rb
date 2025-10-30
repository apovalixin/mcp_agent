#!/usr/bin/env ruby
# frozen_string_literal: true

# ==============================================================================
# Скрипт для управления зашифрованными credentials
# ==============================================================================
# Автоматически создан McpAgent gem
# 
# Использование:
#   ./credentials.rb edit   - Редактировать credentials в текстовом редакторе
#   ./credentials.rb show   - Показать текущие credentials
#
# Примеры:
#   ruby credentials.rb edit
#   ruby credentials.rb show
# ==============================================================================

require 'bundler/setup'
require 'mcp_agent'

# Получаем команду из аргументов
command = ARGV[0]

case command
when 'edit'
  begin
    McpAgent::Credentials.edit
  rescue => e
    puts "\n❌ Ошибка: #{e.message}"
    puts "\nПроверьте:"
    puts "  1. Установлены ли все зависимости (bundle install)"
    puts "  2. Существует ли директория config/"
    exit 1
  end

when 'show'
  begin
    McpAgent::Credentials.show
  rescue => e
    puts "\n❌ Ошибка: #{e.message}"
    puts "\nПроверьте:"
    puts "  1. Существует ли config/credentials.yml.enc"
    puts "  2. Существует ли config/master.key"
    puts "  3. Запустите './credentials.rb edit' для создания credentials"
    exit 1
  end

else
  puts <<~HELP
    
    🔐 Управление credentials для агента
    
    Использование:
      ./credentials.rb <команда>
    
    Доступные команды:
      edit    Редактировать credentials в текстовом редакторе (nano)
      show    Показать текущие credentials
    
    Примеры:
      ./credentials.rb edit
      ./credentials.rb show
    
    Файлы:
      config/credentials.yml.enc  - зашифрованный файл с credentials
      config/master.key           - ключ шифрования (НЕ коммитить в git!)
    
  HELP
  exit 1
end

