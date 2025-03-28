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

          host = req['host'] || req.uri&.host
          # Get the full request path
          request_path = get_full_request_path(req)

          # Only log if route should be logged
          if ApiLogger.configuration.should_log_route?(request_path, host)
            ApiLogger.log(
              endpoint: request_path,
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
          # Get the full request path
          host = req['host'] || req.uri&.host
          request_path = get_full_request_path(req)

          # Only log if route should be logged
          if ApiLogger.configuration.should_log_route?(request_path, host)
            ApiLogger.log(
              endpoint: request_path,
              http_method: req.method,
              request_params: req.body || body,
              request_headers: req.each_header.to_h,
              error_message: e.message
            )
          end
          raise e
        end

        private

        def get_full_request_path(req)
          return req.path if req.path.start_with?('/')

          uri = req.uri
          return '/' unless uri

          # Get the path from the URI
          path = uri.path
          path = '/' if path.blank? || path.empty?

          # Add query string if present
          path += "?#{uri.query}" if uri.query

          path
        end
      end
    end

    delegate :call, to: :@app
  end
end
