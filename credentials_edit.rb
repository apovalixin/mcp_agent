#!/usr/bin/env ruby
# frozen_string_literal: true

# Очищаем проблемную переменную окружения RUBYOPT
ENV.delete('RUBYOPT')

# Переходим в директорию скрипта
Dir.chdir(File.dirname(__FILE__))

require 'bundler/setup'
require 'mcp_agent'

McpAgent::Credentials.edit

