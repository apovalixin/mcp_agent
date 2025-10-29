# McpAgent

[![Ruby Version](https://img.shields.io/badge/ruby-%3E%3D%203.4.0-ruby.svg)](https://www.ruby-lang.org)
[![Gem Version](https://img.shields.io/badge/version-1.0.1-blue.svg)](https://rubygems.org/gems/mcp_agent)
[![License](https://img.shields.io/badge/license-MIT-green.svg)](LICENSE.txt)

> **Status:** ✅ Production ready для Telegram транспорта | ⚠️ RabbitMQ в разработке

Универсальная платформа для быстрого создания интеллектуальных агентов с поддержкой MCP (Model Context Protocol).

## 🎯 Возможности

- **Быстрое создание агентов** - создайте полнофункционального агента за 5 минут
- **MCP интеграция** - подключение к любому MCP-совместимому серверу
- **Динамическая загрузка инструментов** - автоматическое обнаружение и использование всех доступных MCP tools
- **Транспорты из коробки** - Telegram Bot и RabbitMQ для межагентного взаимодействия
- **AI обработка** - интеграция с OpenAI (GPT-4.1-mini, GPT-4o, GPT-4o-mini)
- **Безопасность** - AES-256-GCM шифрование credentials (аналог Rails)
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

# URL вашего MCP сервера
mcp:
  url: https://your-mcp-server.com/mcp

# AI настройки
ai:
  model: gpt-4.1-mini  # или gpt-4o, gpt-4o-mini

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

### 4. Создайте credentials

```bash
./credentials_edit.rb
```

Добавьте в открывшийся редактор:

```yaml
# OpenAI API Key
openai_api_key: sk-your-key-here

# MCP Server Authentication Token
mcp_auth_token: Bearer your-token-here

# Telegram Bot Token (опционально)
telegram_token: 123456789:ABCdefGHIjklMNOpqrsTUVwxyz
```

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

mcp:
  url: https://example.com/mcp  # Обязательно: URL MCP сервера

ai:
  model: gpt-4.1-mini       # Опционально: модель AI (default: gpt-4.1-mini)

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

Credentials хранятся в зашифрованном виде в `config/credentials.yml.enc`.

**Команды:**

```bash
# Создать/редактировать
./credentials_edit.rb

# Показать расшифрованные credentials
./credentials_show.rb
```

**Master key** хранится в:
- `config/master.key` (не коммитить в git!)
- Или в переменной окружения `ENV['MASTER_KEY']`

> **Примечание:** Методы `edit` и `show` автоматически обрабатывают конфликты с переменной окружения `RUBYOPT`, поэтому команды работают корректно в любом окружении.

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
gem install ./mcp_agent-1.0.1.gem
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
- [ ] v1.1.0 - Полная поддержка RabbitMQ
- [ ] v1.2.0 - Дополнительные транспорты (HTTP, WebSocket)
- [ ] v2.0.0 - Поддержка других AI провайдеров (Anthropic, Google)

---

**Версия:** 1.0.0 | **Ruby:** >= 3.4.0 | **Лицензия:** MIT

