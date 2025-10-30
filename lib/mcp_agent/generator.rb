# frozen_string_literal: true

require 'fileutils'

module McpAgent
  # ==============================================================================
  # Generator - Генератор файлов для проектов агентов
  # ==============================================================================
  module Generator
    class << self
      # Инициализировать новый проект агента
      def init_agent(target_dir = '.', agent_name: 'agent')
        templates_dir = File.expand_path('../../templates', __dir__)
        
        puts "\n🚀 Инициализация нового агента McpAgent..."
        puts "─" * 60
        
        # Создаём или обновляем Gemfile
        gemfile_source = File.join(templates_dir, 'Gemfile')
        gemfile_dest = File.join(target_dir, 'Gemfile')
        
        if File.exist?(gemfile_dest)
          # Проверяем, есть ли уже mcp_agent в Gemfile
          gemfile_content = File.read(gemfile_dest)
          if gemfile_content.include?('mcp_agent')
            puts "⚠️  Gemfile уже содержит mcp_agent, пропускаем"
          else
            # Добавляем mcp_agent в существующий Gemfile
            File.open(gemfile_dest, 'a') do |f|
              f.puts "\n# McpAgent - универсальная платформа для создания интеллектуальных агентов"
              f.puts "gem 'mcp_agent', git: 'https://github.com/apovalixin/mcp_agent.git'"
            end
            puts "✅ Добавлен mcp_agent в существующий Gemfile"
          end
        else
          FileUtils.cp(gemfile_source, gemfile_dest)
          puts "✅ Создан Gemfile"
        end
        
        # Создаём директорию config
        config_dir = File.join(target_dir, 'config')
        FileUtils.mkdir_p(config_dir)
        puts "✅ Создана директория config/"
        
        # Копируем settings.yml
        settings_source = File.join(templates_dir, 'settings.yml')
        settings_dest = File.join(config_dir, 'settings.yml')
        
        if File.exist?(settings_dest)
          puts "⚠️  config/settings.yml уже существует, пропускаем"
        else
          FileUtils.cp(settings_source, settings_dest)
          puts "✅ Создан config/settings.yml"
        end
        
        # Копируем agent.rb
        agent_source = File.join(templates_dir, 'agent.rb')
        agent_dest = File.join(target_dir, "#{agent_name}.rb")
        
        if File.exist?(agent_dest)
          puts "⚠️  #{agent_name}.rb уже существует, пропускаем"
        else
          FileUtils.cp(agent_source, agent_dest)
          File.chmod(0755, agent_dest)
          puts "✅ Создан #{agent_name}.rb"
        end
        
        # Устанавливаем credentials скрипт
        credentials_source = File.join(templates_dir, 'credentials.rb')
        credentials_dest = File.join(target_dir, 'credentials.rb')
        
        if File.exist?(credentials_dest)
          puts "⚠️  credentials.rb уже существует, пропускаем"
        else
          FileUtils.cp(credentials_source, credentials_dest)
          File.chmod(0755, credentials_dest)
          puts "✅ Создан credentials.rb"
        end
        
        # Проверяем/создаём .gitignore
        ensure_gitignore(target_dir)
        
        puts "─" * 60
        puts "\n✅ Инициализация завершена!"
        puts "\nСледующие шаги:"
        puts "  1. Установите зависимости:"
        puts "     bundle install"
        puts ""
        puts "  2. Настройте credentials:"
        puts "     ./credentials.rb edit"
        puts ""
        puts "  3. Отредактируйте config/settings.yml:"
        puts "     - Укажите название агента (agent.name)"
        puts "     - Укажите URL вашего MCP сервера (mcp.url)"
        puts "     - Настройте system_prompt под задачу агента"
        puts ""
        puts "  4. Запустите агента:"
        puts "     ruby #{agent_name}.rb"
        puts ""
        
      rescue => e
        puts "\n❌ Ошибка инициализации: #{e.message}"
        raise
      end
      
      # Установить скрипты управления credentials в проект (для обратной совместимости)
      def install_credentials_scripts(target_dir = '.')
        templates_dir = File.expand_path('../../templates', __dir__)
        
        source = File.join(templates_dir, 'credentials.rb')
        destination = File.join(target_dir, 'credentials.rb')
        
        puts "\n📦 Установка скрипта управления credentials..."
        puts "─" * 60
        
        if File.exist?(destination)
          puts "⚠️  credentials.rb уже существует, пропускаем"
        else
          FileUtils.cp(source, destination)
          File.chmod(0755, destination)
          puts "✅ Создан credentials.rb"
        end
        
        # Проверяем/создаём .gitignore
        ensure_gitignore(target_dir)
        
        puts "─" * 60
        puts "\n✅ Установка завершена!"
        puts "\nИспользование:"
        puts "  ./credentials.rb edit  - Редактировать credentials"
        puts "  ./credentials.rb show  - Показать текущие credentials"
        puts "\n⚠️  ВАЖНО: config/master.key не должен попадать в git!"
        
      rescue => e
        puts "\n❌ Ошибка установки: #{e.message}"
        raise
      end
      
      private
      
      def ensure_gitignore(target_dir)
        gitignore_path = File.join(target_dir, '.gitignore')
        
        required_entries = [
          'config/master.key'
        ]
        
        if File.exist?(gitignore_path)
          content = File.read(gitignore_path)
          needs_update = false
          
          required_entries.each do |entry|
            unless content.include?(entry)
              content += "\n#{entry}" unless content.end_with?("\n")
              needs_update = true
            end
          end
          
          if needs_update
            File.write(gitignore_path, content)
            puts "✅ Обновлён .gitignore"
          end
        else
          gitignore_content = <<~GITIGNORE
            # McpAgent credentials
            config/master.key
          GITIGNORE
          
          File.write(gitignore_path, gitignore_content)
          puts "✅ Создан .gitignore"
        end
      end
    end
  end
end

