# Contributing to McpAgent

Спасибо, что хотите внести вклад в McpAgent! 🎉

## Как внести вклад

### Сообщить о баге

1. Проверьте, что баг еще не был сообщен в [Issues](https://github.com/apovalixin/mcp_agent/issues)
2. Создайте новый issue с использованием шаблона Bug Report
3. Включите как можно больше деталей:
   - Версия Ruby
   - Версия McpAgent
   - Шаги для воспроизведения
   - Ожидаемое и фактическое поведение
   - Логи

### Предложить новую функцию

1. Проверьте [Issues](https://github.com/apovalixin/mcp_agent/issues) и [Roadmap](README.md#-roadmap)
2. Создайте новый issue с использованием шаблона Feature Request
3. Опишите:
   - Проблему, которую решает функция
   - Предлагаемое решение
   - Альтернативы

### Отправить Pull Request

1. Fork репозитория
2. Создайте ветку для вашей функции:
   ```bash
   git checkout -b feature/amazing-feature
   ```

3. Внесите изменения:
   - Следуйте стилю кода проекта
   - Добавьте комментарии к коду
   - Обновите документацию при необходимости

4. Зафиксируйте изменения:
   ```bash
   git commit -am 'Add amazing feature'
   ```

5. Push в вашу ветку:
   ```bash
   git push origin feature/amazing-feature
   ```

6. Откройте Pull Request

## Стиль кода

- Следуйте [Ruby Style Guide](https://rubystyle.guide/)
- Используйте `frozen_string_literal: true`
- Пишите комментарии для сложной логики
- Используйте осмысленные имена переменных и методов

## Структура коммитов

Используйте понятные сообщения коммитов:

```
Add: Добавление новой функции
Fix: Исправление бага
Update: Обновление существующей функциональности
Refactor: Рефакторинг кода
Docs: Обновление документации
Test: Добавление или изменение тестов
```

Примеры:
- `Add: Support for WebSocket transport`
- `Fix: Telegram bot markdown parsing`
- `Update: Improve error handling in MCP client`

## Разработка

### Настройка окружения

```bash
# Клонировать репозиторий
git clone git@github.com:apovalixin/mcp_agent.git
cd mcp_agent

# Установить зависимости
bundle install

# Проверить синтаксис
find lib -name "*.rb" -exec ruby -c {} \;

# Собрать gem
gem build mcp_agent.gemspec
```

### Локальное тестирование

Для тестирования изменений локально:

```ruby
# В Gemfile вашего проекта
gem 'mcp_agent', path: '/path/to/mcp_agent'
```

## Тесты

> **Примечание:** Тесты находятся в разработке и будут добавлены в следующих версиях.

Когда тесты будут добавлены:

```bash
# Запустить все тесты
bundle exec rspec

# Запустить конкретный тест
bundle exec rspec spec/mcp_agent/agent_spec.rb
```

## Документация

- Обновляйте README.md при добавлении новой функциональности
- Документируйте публичные API в комментариях к коду
- Добавляйте примеры использования

## Вопросы?

- Создайте issue с вопросом

## Лицензия

Внося вклад в проект, вы соглашаетесь с тем, что ваш вклад будет лицензирован под [MIT License](LICENSE.txt).

---

Спасибо за ваш вклад! 🚀

