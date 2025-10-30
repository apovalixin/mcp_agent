# McpAgent

[![Ruby Version](https://img.shields.io/badge/ruby-%3E%3D%203.4.7-ruby.svg)](https://www.ruby-lang.org)
[![Gem Version](https://img.shields.io/badge/version-1.0.3-blue.svg)](https://rubygems.org/gems/mcp_agent)
[![License](https://img.shields.io/badge/license-MIT-green.svg)](LICENSE.txt)

> **Статус:** ✅ Production ready для Telegram транспорта | ⚠️ RabbitMQ в разработке

Универсальная платформа для быстрого создания интеллектуальных агентов с поддержкой MCP (Model Context Protocol).

## 🎯 Возможности

- **Быстрое создание агентов** - создайте полнофункционального агента за 5 минут
- **MCP интеграция** - подключение к любому MCP-совместимому серверу
- **Динамическая загрузка инструментов** - автоматическое обнаружение и использование всех доступных MCP tools
- **Транспорты из коробки** - Telegram Bot и RabbitMQ для межагентного взаимодействия
- **AI обработка** - интеграция с OpenAI
- **🔐 Безопасное хранение credentials** - зашифрованные credentials в стиле Rails
- **Гибкая конфигурация** - простое управление через YAML файлы и переменные окружения
- **Модульная архитектура** - переиспользуемые компоненты
- **Логирование** - структурированное JSON логирование

## 📦 Установка

Добавьте в ваш `Gemfile`:

```ruby
gem 'mcp_agent', git: 'https://github.com/apovalixin/mcp_agent.git'
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

Создайте полнофункционального агента за **2 минуты**!

### 1. Создайте проект

```bash
mkdir my_agent && cd my_agent
```

### 2. Инициализируйте агента

Одна команда создаст всё необходимое:

```bash
gem install mcp_agent
mcp_agent init
```

Или если у вас уже установлен bundler:

```bash
# Только для первого раза - установка gem из GitHub
echo "source 'https://rubygems.org'" > Gemfile
echo "gem 'mcp_agent', git: 'https://github.com/apovalixin/mcp_agent.git'" >> Gemfile
bundle install

# Инициализация агента
bundle exec mcp_agent init
```

Эта команда создаст:
- `Gemfile` - зависимости проекта (если не существует)
- `config/settings.yml` - конфигурация агента
- `agent.rb` - главный файл агента
- `credentials.rb` - скрипт управления секретами
- `.gitignore` - с настройками безопасности

Вы можете указать свое название для главного файла:

```bash
bundle exec mcp_agent init my_bot  # Создаст my_bot.rb
```

### 3. Установите зависимости

```bash
bundle install
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

**Готово!** 🎉 Ваш агент запущен и готов к работе через Telegram.

## 🔐 Управление Credentials

### Основные команды

```bash
# Редактировать credentials
./credentials.rb edit

# Показать текущие credentials
./credentials.rb show

# Справка
./credentials.rb
```

### Приоритеты загрузки

Агент автоматически загружает credentials в следующем порядке:

1. **Зашифрованный файл** `config/credentials.yml.enc` (рекомендуется)
2. **Конфигурация** из `config/settings.yml` секции `credentials`
3. **Переменные окружения** (`OPENAI_API_KEY`, `MCP_AUTH_TOKEN`, и т.д.)

### Безопасность

- `config/credentials.yml.enc` - зашифрованный файл (безопасно коммитить в git)
- `config/master.key` - ключ шифрования (**НЕ коммитить в git!**)
- Автоматически добавляется в `.gitignore`

### Для новых разработчиков

Если вы клонировали проект:

1. Запросите файл `config/master.key` у администратора
2. Поместите его в директорию `config/`
3. Убедитесь в правах доступа: `chmod 600 config/master.key`
4. Проверьте: `./credentials.rb show`

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

# Собрать gem
gem build mcp_agent.gemspec

# Установить локально
gem install ./mcp_agent-1.0.3.gem
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

### Пример 3: Работа с credentials программно

```ruby
require 'mcp_agent'

# Просмотр credentials
McpAgent::Credentials.show

# Чтение credentials как Hash
creds = McpAgent::Credentials.read
puts creds[:openai_api_key]
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
- [x] v1.0.1 - Первая версия credentials management
- [x] v1.0.2 - Улучшенная система credentials с единым скриптом
- [x] v1.0.3 - Генератор агентов (команда `init`)
- [ ] v1.1.0 - Полная поддержка RabbitMQ
- [ ] v1.2.0 - Дополнительные транспорты (HTTP, WebSocket)
- [ ] v2.0.0 - Поддержка других AI провайдеров (Anthropic, Google)

---

**Версия:** 1.0.3 | **Ruby:** >= 3.4.7 | **Лицензия:** MIT
