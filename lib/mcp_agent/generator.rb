# frozen_string_literal: true

require 'fileutils'

module McpAgent
  # ==============================================================================
  # Generator - Генератор файлов для проектов агентов
  # ==============================================================================
  module Generator
    class << self
      # Установить скрипты управления credentials в проект
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

