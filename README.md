# McpAgent

[![Ruby Version](https://img.shields.io/badge/ruby-%3E%3D%203.4.0-ruby.svg)](https://www.ruby-lang.org)
[![Gem Version](https://img.shields.io/badge/version-1.1.0-blue.svg)](https://rubygems.org/gems/mcp_agent)
[![License](https://img.shields.io/badge/license-MIT-green.svg)](LICENSE.txt)

> **Status:** ✅ Production ready для Telegram транспорта | ⚠️ RabbitMQ в разработке

Универсальная платформа для быстрого создания интеллектуальных агентов с поддержкой MCP (Model Context Protocol).

## 🎯 Возможности

- **Быстрое создание агентов** - создайте полнофункционального агента за 5 минут
- **MCP интеграция** - подключение к любому MCP-совместимому серверу
- **Динамическая загрузка инструментов** - автоматическое обнаружение и использование всех доступных MCP tools
- **Транспорты из коробки** - Telegram Bot и RabbitMQ для межагентного взаимодействия
- **AI обработка** - интеграция с OpenAI
- **Гибкая конфигурация** - простое управление через YAML файлы и переменные окружения
- **Модульная архитектура** - переиспользуемые компоненты
- **Логирование** - структурированное JSON логирование

## 📦 Установка

Добавьте в ваш `Gemfile`:

```ruby
gem 'mcp_agent'
```

Или установите напрямую:

```bash
gem install mcp_agent
```

Для локальной разработки:

```ruby
gem 'mcp_agent', path: '../mcp_agent'
```

## 🚀 Быстрый старт

### 1. Создайте структуру проекта

```bash
mkdir my_agent && cd my_agent
bundle init
```

### 2. Добавьте gem в Gemfile

```ruby
source 'https://rubygems.org'

ruby '3.4.7'

gem 'mcp_agent'
```

### 3. Создайте конфигурацию

Создайте файл `config/settings.yml`:

```yaml
agent:
  name: my_agent
  version: 1.0.0
  log_level: INFO

# Credentials (расшифрованные) - опционально, если не указаны используются ENV переменные
credentials:
  openai_api_key: sk-your-key-here
  mcp_auth_token: your-token-here
  telegram_token: 123456789:ABCdefGHIjklMNOpqrsTUVwxyz

# URL вашего MCP сервера
mcp:
  url: https://your-mcp-server.com/mcp

# AI настройки
ai:
  model: gpt-4.1-mini 

# Транспорты
transports:
  rabbitmq:
    enabled: true
    host: localhost
    port: 5672

# Промпт для вашего агента
processing:
  system_prompt: |
    Ты - интеллектуальный помощник.
    Твоя задача - помогать пользователям с их запросами.
    Используй предоставленный контекст из MCP инструментов.
```

### 4. Настройте credentials

Есть два способа передачи credentials в гем:

**Способ 1: Через конфиг (расшифрованные credentials)**

В `config/settings.yml` добавьте секцию credentials с уже расшифрованными ключами:

```yaml
credentials:
  openai_api_key: sk-your-key-here
  mcp_auth_token: your-token-here
  telegram_token: 123456789:ABCdefGHIjklMNOpqrsTUVwxyz
  rabbitmq_username: guest
  rabbitmq_password: guest
```

**Способ 2: Через переменные окружения**

Если секция `credentials` не содержит ключей, гем автоматически использует переменные окружения:

```bash
export OPENAI_API_KEY=sk-your-key-here
export MCP_AUTH_TOKEN=your-token-here
export TELEGRAM_TOKEN=123456789:ABCdefGHIjklMNOpqrsTUVwxyz
```

> **Для Rails приложений:** Используйте Rails credentials для хранения зашифрованных ключей и передавайте расшифрованные значения через конфиг. См. секцию "Интеграция с Rails" ниже.

### 5. Создайте главный файл

Создайте `my_agent.rb`:

```ruby
#!/usr/bin/env ruby
# frozen_string_literal: true

require 'mcp_agent'

# Создание и запуск агента
agent = McpAgent::Agent.new(config_path: 'config/settings.yml')

puts ""
puts "🤖 #{agent.name} v#{agent.version}"
puts ""
puts "📡 Настройка транспортов для взаимодействия:"
puts ""

agent.setup_transports
puts ""

agent.run
```

### 6. Запустите агента

```bash
chmod +x my_agent.rb
ruby my_agent.rb
```

**Готово!** Ваш агент запущен и готов к работе через Telegram.

## 📚 Подробная документация

### Структура конфигурации

```yaml
agent:
  name: agent_name          # Обязательно: имя агента
  version: 1.0.0            # Опционально: версия (default: 1.0.0)
  log_level: INFO           # Опционально: DEBUG, INFO, WARN, ERROR

credentials:                # Опционально: расшифрованные credentials
  openai_api_key: sk-...    # Если не указано, используется ENV['OPENAI_API_KEY']
  mcp_auth_token: Bearer... # Если не указано, используется ENV['MCP_AUTH_TOKEN']
  telegram_token: 123...    # Если не указано, используется ENV['TELEGRAM_TOKEN']
  rabbitmq_username: guest  # Если не указано, используется ENV['RABBITMQ_USERNAME']
  rabbitmq_password: guest  # Если не указано, используется ENV['RABBITMQ_PASSWORD']

mcp:
  url: https://example.com/mcp  # Обязательно: URL MCP сервера

ai:
  model: gpt-4.1-mini  

transports:
  rabbitmq:
    enabled: true           # Опционально: включить RabbitMQ
    host: localhost         # Опционально: хост RabbitMQ
    port: 5672              # Опционально: порт RabbitMQ
    exchange: agents        # Опционально: exchange name
    # queue и routing_key генерируются автоматически

processing:
  system_prompt: |          # Обязательно: промпт для AI
    Описание роли агента...
```

### Credentials

Гем ожидает получить **уже расшифрованные** credentials одним из двух способов:

**1. Через конфигурационный файл (для разработки)**

Добавьте расшифрованные credentials прямо в `config/settings.yml`:

```yaml
credentials:
  openai_api_key: sk-your-key-here
  mcp_auth_token: your-token-here
  telegram_token: 123456789:ABCdefGHIjklMNOpqrsTUVwxyz
```

**2. Через переменные окружения (для production)**

Если секция `credentials` пустая или отсутствует, используются ENV переменные:
- `OPENAI_API_KEY`
- `MCP_AUTH_TOKEN`
- `TELEGRAM_TOKEN`
- `RABBITMQ_USERNAME`
- `RABBITMQ_PASSWORD`

### Интеграция с Rails (зашифрованные credentials)

Для Rails приложений рекомендуется использовать встроенный механизм `credentials.yml.enc`:

**1. Создайте скрипт для расшифровки** (`lib/tasks/agent.rake`):

```ruby
namespace :agent do
  desc "Generate agent config with decrypted credentials"
  task :generate_config => :environment do
    config = {
      'agent' => {
        'name' => 'my_agent',
        'version' => '1.0.0',
        'log_level' => 'INFO'
      },
      'credentials' => {
        'openai_api_key' => Rails.application.credentials.openai_api_key,
        'mcp_auth_token' => Rails.application.credentials.mcp_auth_token,
        'telegram_token' => Rails.application.credentials.telegram_token
      },
      'mcp' => {
        'url' => Rails.application.credentials.mcp_url
      },
      'processing' => {
        'system_prompt' => "Твой промпт здесь..."
      }
    }
    
    File.write('config/agent_settings.yml', config.to_yaml)
    puts "✅ Config generated with decrypted credentials"
  end
end
```

**2. Добавьте ключи в Rails credentials**:

```bash
rails credentials:edit
```

```yaml
openai_api_key: sk-your-key-here
mcp_auth_token: Bearer your-token-here
telegram_token: 123456789:ABCdefGHIjklMNOpqrsTUVwxyz
mcp_url: https://your-mcp-server.com/mcp
```

**3. Генерируйте конфиг перед запуском агента**:

```bash
rake agent:generate_config
ruby my_agent.rb  # использует config/agent_settings.yml
```

> **Безопасность:** Файл `config/agent_settings.yml` с расшифрованными credentials добавьте в `.gitignore`!

### Программный доступ к Agent

```ruby
require 'mcp_agent'

# Создание агента
agent = McpAgent::Agent.new(config_path: 'config/settings.yml')

# Обработка запроса напрямую
response = agent.process_query("Какая погода сегодня?")
puts response[:content][0][:text]

# Настройка транспортов
agent.setup_transports

# Запуск (блокирующий)
agent.run

# Или запуск с ручным управлением
agent.start
sleep 100
agent.stop
```

### Создание специализированных агентов

Вы можете создать несколько агентов с разными `system_prompt` для разных задач:

**HR Агент:**
```yaml
processing:
  system_prompt: |
    Ты - HR специалист компании.
    Помогаешь с вопросами о команде, навыках специалистов.
```

**Финансовый агент:**
```yaml
processing:
  system_prompt: |
    Ты - финансовый аналитик компании.
    Работаешь с транзакциями, балансами, отчетами.
```

**Агент поддержки:**
```yaml
processing:
  system_prompt: |
    Ты - агент технической поддержки.
    Помогаешь клиентам решать проблемы.
```

## 🏗️ Архитектура

```
┌─────────────────────────────────────────┐
│         Пользователи                    │
│    (Telegram, CLI, другие агенты)       │
└─────────────────┬───────────────────────┘
                  │
         ┌────────▼────────┐
         │  Transports     │
         │  - Telegram     │
         │  - RabbitMQ     │
         └────────┬────────┘
                  │
         ┌────────▼────────┐
         │   Agent Core    │
         │  - AI Process   │
         │  - Context      │
         └────────┬────────┘
                  │
         ┌────────▼────────┐
         │   MCP Client    │
         │ (Dynamic Tools) │
         └────────┬────────┘
                  │
         ┌────────▼────────┐
         │   MCP Server    │
         │   (Data Store)  │
         └─────────────────┘
```

## 🔌 Транспорты

### Telegram Bot ✅ Production Ready

Автоматически активируется при наличии `telegram_token` в credentials.

**Возможности:**
- Обработка текстовых сообщений
- Markdown форматирование ответов
- Команды `/start` и `/help`
- Индикатор "печатает..."
- Полностью протестирован в продакшене

### RabbitMQ ⚠️ В разработке

Подготовлена инфраструктура для межагентного взаимодействия:
- Point-to-point сообщения
- Broadcast
- RPC паттерн

**Статус:** Базовая структура готова, активная разработка. Ожидается в v1.1.0.

## 🛠️ Разработка

```bash
# Клонировать репозиторий
git clone https://github.com/apovalixin/mcp_agent.git
cd mcp_agent

# Установить зависимости
bundle install

# Запустить тесты
bundle exec rspec

# Собрать gem
gem build mcp_agent.gemspec

# Установить локально
gem install ./mcp_agent-1.1.0.gem
```

## 📝 Примеры

### Пример 1: Простой агент

```ruby
require 'mcp_agent'

agent = McpAgent::Agent.new
agent.setup_transports
agent.run
```

### Пример 2: Обработка запроса

```ruby
require 'mcp_agent'

agent = McpAgent::Agent.new
response = agent.process_query("Расскажи о компании")
puts response[:content][0][:text]
```

### Пример 3: Кастомный транспорт

```ruby
class CustomTransport < McpAgent::Transport
  def start
    @running = true
    puts "Custom transport started"
  end
  
  def send_message(recipient, message)
    # Ваша логика отправки
  end
end

agent = McpAgent::Agent.new
custom = CustomTransport.new(agent)
agent.transports << custom
agent.run
```

## 🤝 Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -am 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## 📄 Лицензия

MIT License. См. [LICENSE.txt](LICENSE.txt) для деталей.

## 🔗 Ссылки

- [GitHub Repository](https://github.com/apovalixin/mcp_agent)
- [RubyGems](https://rubygems.org/gems/mcp_agent)
- [MCP Protocol](https://modelcontextprotocol.io/)
- [OpenAI API](https://platform.openai.com/docs)
- [Telegram Bot API](https://core.telegram.org/bots/api)

## 📞 Поддержка

- GitHub Issues: https://github.com/apovalixin/mcp_agent/issues

## 🗺️ Roadmap

- [x] v1.0.0 - Базовая функциональность + Telegram
- [x] v1.1.0 - Улучшенная работа с credentials, интеграция с Rails
- [ ] v1.2.0 - Полная поддержка RabbitMQ
- [ ] v1.3.0 - Дополнительные транспорты (HTTP, WebSocket)
- [ ] v2.0.0 - Поддержка других AI провайдеров (Anthropic, Google)

---

**Версия:** 1.1.0 | **Ruby:** >= 3.4.0 | **Лицензия:** MIT

