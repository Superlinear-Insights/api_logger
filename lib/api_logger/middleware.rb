module ApiLogger
  class Middleware
    def initialize(app)
      @app = app
    end

    def call(env)
      # Apply our patch only if not already applied
      unless Net::HTTP.method_defined?(:request_with_api_logger)
        apply_http_patch
      end
      
      @app.call(env)
    end
    
    private
    
    def apply_http_patch
      Net::HTTP.class_eval do
        # Only patch if we haven't already
        unless method_defined?(:request_with_api_logger)
          # Keep reference to the current 'request' method, which might already be patched by Sentry
          alias_method :request_without_api_logger, :request
          
          # Define our wrapper method
          def request_with_api_logger(req, body = nil, &block)
            # Prevent recursion
            if Thread.current[:api_logger_active]
              return request_without_api_logger(req, body, &block)
            end
            
            Thread.current[:api_logger_active] = true
            begin
              # Call the existing chain (which might include Sentry's instrumentation)
              response = request_without_api_logger(req, body, &block)
              
              # Only log after we get the response
              host = req['host'] || self.address
              path = req.path
              
              if ApiLogger.configuration.should_log_route?(path, host)
                ApiLogger.log(
                  endpoint: path,
                  http_method: req.method,
                  request_params: req.body || body,
                  request_headers: req.each_header.to_h,
                  response_body: response.body,
                  response_headers: response.each_header.to_h,
                  response_status: response.code.to_i
                )
              end
              
              response
            rescue => e
              # Log errors
              host = req['host'] || self.address
              path = req.path
              
              if ApiLogger.configuration.should_log_route?(path, host)
                ApiLogger.log(
                  endpoint: path,
                  http_method: req.method,
                  request_params: req.body || body,
                  request_headers: req.each_header.to_h,
                  error_message: e.message
                )
              end
              
              raise
            ensure
              Thread.current[:api_logger_active] = nil
            end
          end
          
          # Complete the method chain
          alias_method :request, :request_with_api_logger
        end
      end
    end
  end
end
