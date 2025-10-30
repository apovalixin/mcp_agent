# McpAgent

[![Ruby Version](https://img.shields.io/badge/ruby-%3E%3D%203.4.7-ruby.svg)](https://www.ruby-lang.org)
[![Gem Version](https://img.shields.io/badge/version-1.0.3-blue.svg)](https://rubygems.org/gems/mcp_agent)
[![License](https://img.shields.io/badge/license-MIT-green.svg)](LICENSE.txt)

> **Статус:** Production ready для Telegram транспорта | ⚠️ RabbitMQ в разработке

Универсальная платформа для быстрого создания интеллектуальных агентов с поддержкой MCP (Model Context Protocol).

## Возможности

- **Быстрое создание агентов** - создайте полнофункционального агента за 5 минут
- **MCP интеграция** - подключение к любому MCP-совместимому серверу
- **Динамическая загрузка инструментов** - автоматическое обнаружение и использование всех доступных MCP tools
- **Транспорты из коробки** - Telegram Bot и RabbitMQ для межагентного взаимодействия
- **AI обработка** - интеграция с OpenAI
- **Безопасное хранение credentials** - зашифрованные credentials в стиле Rails
- **Гибкая конфигурация** - простое управление через YAML файлы и переменные окружения
- **Модульная архитектура** - переиспользуемые компоненты
- **Логирование** - структурированное JSON логирование

## Установка

Добавьте в ваш `Gemfile`:

```ruby
gem 'mcp_agent', git: 'https://github.com/apovalixin/mcp_agent.git'
```

Затем выполните:

```bash
bundle install
```

Для локальной разработки:

```ruby
gem 'mcp_agent', path: '../mcp_agent'
```

## Быстрый старт

Создайте полнофункционального агента за **2 минуты**!

### 1. Создайте проект

```bash
mkdir my_agent && cd my_agent
```

### 2. Инициализируйте Bundler и установите mcp_agent

```bash
bundle init
bundle add mcp_agent --git https://github.com/apovalixin/mcp_agent.git
```

### 3. Инициализируйте агента

```bash
bundle exec mcp_agent init
```

Эта команда создаст:
- `config/settings.yml` - конфигурация агента
- `agent.rb` - главный файл агента
- `credentials.rb` - скрипт управления секретами
- `.gitignore` - с настройками безопасности

Вы можете указать свое название для главного файла:

```bash
bundle exec mcp_agent init my_bot  # Создаст my_bot.rb
```

### 4. Настройте credentials

```bash
./credentials.rb edit
```

Откроется редактор (nano) для настройки секретов:

```yaml
# OpenAI API Key (обязательно)
openai_api_key: sk-your-key-here

# MCP Server Authentication Token (обязательно)
mcp_auth_token: your-token-here

# Telegram Bot Token (опционально)
telegram_token: 123456789:ABCdefGHIjklMNOpqrsTUVwxyz

# RabbitMQ credentials (опционально)
rabbitmq_username: guest
rabbitmq_password: guest
```

Сохраните и закройте редактор (Ctrl+O, Enter, Ctrl+X).

### 5. Отредактируйте конфигурацию

Откройте `config/settings.yml` и настройте:

```yaml
agent:
  name: my_agent              # Название вашего агента
  version: 1.0.0
  log_level: INFO

mcp:
  url: https://your-mcp-server.com/mcp  # URL вашего MCP сервера

ai:
  model: gpt-4.1-mini

processing:
  system_prompt: |
    Ты - интеллектуальный помощник.
    Твоя задача - помогать пользователям с их запросами.
    Используй предоставленный контекст из MCP инструментов.
```

### 6. Запустите агента

```bash
ruby agent.rb
```

**Готово!** Ваш агент запущен и готов к работе через Telegram.

## Управление Credentials

### Основные команды

```bash
# Редактировать credentials
./credentials.rb edit

# Показать текущие credentials
./credentials.rb show

# Справка
./credentials.rb
```
### Безопасность

- `config/credentials.yml.enc` - зашифрованный файл (безопасно коммитить в git)
- `config/master.key` - ключ шифрования (**НЕ коммитить в git!**)
- Автоматически добавляется в `.gitignore`

## Подробная документация

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

## Транспорты

### Telegram Bot Production Ready

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

## 📄 Лицензия

MIT License. См. [LICENSE.txt](LICENSE.txt) для деталей.

## 🔗 Ссылки

- [GitHub Repository](https://github.com/apovalixin/mcp_agent)
- [RubyGems](https://rubygems.org/gems/mcp_agent)
- [MCP Protocol](https://modelcontextprotocol.io/)
- [OpenAI API](https://platform.openai.com/docs)
- [Telegram Bot API](https://core.telegram.org/bots/api)

## 🗺️ Roadmap

- [x] v1.0.0 - Базовая функциональность + Telegram
- [x] v1.0.1 - Первая версия credentials management
- [x] v1.0.2 - Улучшенная система credentials с единым скриптом
- [x] v1.0.3 - Генератор агентов (команда `init`)
- [ ] v1.1.0 - Полная поддержка RabbitMQ
- [ ] v1.2.0 - Дополнительные транспорты (HTTP, WebSocket)
- [ ] v2.0.0 - Поддержка других AI провайдеров (Anthropic, Google)

---

**Версия:** 1.0.3 | **Ruby:** >= 3.4.7 | **Лицензия:** MIT
