require 'rails'
require 'api_logger/middleware'

module ApiLogger
  class Railtie < Rails::Railtie
    rake_tasks do
      load "tasks/api_logger_tasks.rake"
    end
    
    generators do
      require "generators/api_logger/install/install_generator"
    end

    # Define the model class when Rails initializes
    config.before_initialize do
      # Create ApiLog constant if it doesn't exist
      unless Object.const_defined?('ApiLog')
        Object.const_set('ApiLog', Class.new(ActiveRecord::Base) do
          self.table_name = ApiLogger.configuration.table_name

          # Add some useful scopes
          scope :recent, -> { order(created_at: :desc) }
          scope :failed, -> { where('response_status >= ?', 400) }
          scope :successful, -> { where('response_status < ?', 400) }
        end)
      end
    end

    # Load middleware as early as possible
    initializer "api_logger.configure_middleware", before: :load_config_initializers do |app|
      if ApiLogger.configuration.enabled && ApiLogger.configuration.use_middleware
        Rails.logger.info "Adding ApiLogger middleware to Rails" if defined?(Rails)
        app.middleware.use ApiLogger::Middleware
      end
    end
  end
end
