# frozen_string_literal: true

require 'faraday'
require 'json'

module McpAgent
  # ==============================================================================
  # McpClient - Динамический клиент для работы с любым MCP сервером
  # ==============================================================================
  class McpClient
    attr_reader :available_tools

    def initialize(mcp_url, auth_token)
      @mcp_url = mcp_url
      @auth_token = auth_token
      @request_id = 0
      @client = Faraday.new(url: @mcp_url) do |f|
        f.adapter Faraday.default_adapter
        f.options.timeout = 30
        f.options.open_timeout = 10
      end

      check_connection
      fetch_and_define_tools
    end

    def call_tool(tool_name, arguments = {})
      call_mcp_tool(tool_name, arguments)
    end

    private

    def check_connection
      request_payload = {
        jsonrpc: '2.0',
        id: 1,
        method: 'tools/list'
      }

      response = @client.post do |req|
        req.headers['Authorization'] = @auth_token
        req.headers['Content-Type'] = 'application/json'
        req.body = request_payload.to_json
      end

      result = JSON.parse(response.body)
      
      if result['error']
        puts "⚠️  MCP сервер недоступен: #{result['error']['message']}"
        false
      else
        true
      end
    rescue => e
      puts "⚠️  Не удалось подключиться к MCP серверу: #{e.message}"
      false
    end

    def fetch_and_define_tools
      request_payload = {
        jsonrpc: '2.0',
        id: 1,
        method: 'tools/list'
      }

      response = @client.post do |req|
        req.headers['Authorization'] = @auth_token
        req.headers['Content-Type'] = 'application/json'
        req.body = request_payload.to_json
      end

      result = JSON.parse(response.body)
      
      if result['error']
        raise ErrorHandler::NetworkError, "Failed to fetch tools: #{result['error']['message']}"
      end

      tools = result.dig('result', 'tools') || []
      @available_tools = tools.map { |tool| tool['name'] }

      define_tool_methods
    rescue => e
      puts "❌ Ошибка загрузки инструментов: #{e.message}"
      @available_tools = []
    end

    def define_tool_methods
      @available_tools.each do |tool_name|
        define_singleton_method(tool_name) do |**arguments|
          call_mcp_tool(tool_name, arguments)
        end
      end
    end

    def call_mcp_tool(tool_name, arguments)
      start_time = Time.now
      @request_id += 1

      request_payload = {
        jsonrpc: '2.0',
        id: @request_id,
        method: 'tools/call',
        params: { name: tool_name, arguments: arguments }
      }

      response = @client.post do |req|
        req.headers['Authorization'] = @auth_token
        req.headers['Content-Type'] = 'application/json'
        req.body = request_payload.to_json
      end

      result = JSON.parse(response.body)
      duration = ((Time.now - start_time) * 1000).round(2)

      if result['error']
        raise ErrorHandler::NetworkError, "MCP Error: #{result['error']['message']}"
      end

      content = result.dig('result', 'content')&.find { |item| item['type'] == 'text' }
      
      if content && content['text']
        ErrorHandler.log(:debug, "MCP tool выполнен", {
          component: 'mcp_client',
          operation: 'call_mcp_tool',
          metadata: { tool_name: tool_name, duration_ms: duration }
        })
        content['text']
      else
        raise ErrorHandler::NetworkError, "Invalid MCP response"
      end
    rescue Faraday::Error => e
      raise ErrorHandler::NetworkError, "MCP connection error: #{e.message}"
    end
  end
end

