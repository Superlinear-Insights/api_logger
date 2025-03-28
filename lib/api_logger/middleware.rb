require 'net/http'

module ApiLogger
  class Middleware
    def initialize(app)
      @app = app

      # Store the original request method
      original_request_method = Net::HTTP.instance_method(:request)

      # Patch the Net::HTTP class
      Net::HTTP.class_eval do
        define_method(:request) do |req, body = nil, &block|
          # Call original request method
          response = original_request_method.bind(self).call(req, body, &block)

          # Only log if middleware is enabled
          if ApiLogger.configuration.enabled && ApiLogger.configuration.use_middleware
            ApiLogger.log(
              endpoint: req.path,
              http_method: req.method,
              request_params: req.body || body,
              request_headers: req.each_header.to_h,
              response_body: response.body,
              response_headers: response.each_header.to_h,
              response_status: response.code.to_i
            )
          end

          response
        rescue StandardError => e
          # Only log if middleware is enabled
          if ApiLogger.configuration.enabled && ApiLogger.configuration.use_middleware
            ApiLogger.log(
              endpoint: req.path,
              http_method: req.method,
              request_params: req.body || body,
              request_headers: req.each_header.to_h,
              error_message: e.message
            )
          end
          raise e
        end
      end
    end

    def call(env)
      @app.call(env)
    end
  end
end
