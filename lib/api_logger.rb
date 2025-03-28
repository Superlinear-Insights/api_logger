require 'api_logger/version'
require 'api_logger/configuration'
require 'api_logger/railtie' if defined?(Rails)
require 'api_logger/generators' if defined?(Rails)

module ApiLogger
  class Error < StandardError; end

  class << self
    attr_writer :configuration

    def configuration
      @configuration ||= Configuration.new
    end

    def configure
      yield(configuration)
    end

    def config
      configuration
    end

    def log(endpoint:, http_method: nil, request_headers: nil, request_params: nil, response_body: nil,
            response_headers: nil, response_status: nil, error_message: nil)
      return unless configuration.enabled

      request_params = prepare_params(request_params)
      request_headers = prepare_headers(request_headers)
      response_body = prepare_response(response_body)
      response_headers = prepare_headers(response_headers)

      # Create the log entry
      klass = get_model_class
      klass.create(
        endpoint: endpoint.to_s,
        http_method: http_method,
        request_headers: request_headers,
        request_params: request_params,
        response_body: response_body,
        response_headers: response_headers,
        response_status: response_status,
        error_message: error_message
      )
    rescue StandardError => e
      Rails.logger.error("ApiLogger failed to log request: #{e.message}") if defined?(Rails)
    end

    private

    def prepare_headers(headers)
      return nil if headers.nil?

      headers.to_h if headers.respond_to?(:to_h)
    end

    def prepare_params(params)
      return nil if params.nil?

      params = params.to_h if params.respond_to?(:to_h)
      params
    end

    def prepare_response(response)
      return nil if response.nil?

      case response
      when String
        begin
          JSON.parse(response)
        rescue StandardError
          response
        end
      else
        response
      end
    end

    def get_model_class
      # Dynamically define model class if it doesn't exist
      model_name = configuration.table_name.classify

      begin
        model_name.constantize
      rescue NameError
        # Define the model class dynamically
        Object.const_set(model_name, Class.new(ActiveRecord::Base) do
          self.table_name = ApiLogger.configuration.table_name
        end)
      end
    end
  end
end
