require 'rails'

module ApiLogger
  class Railtie < Rails::Railtie
    rake_tasks do
      load "tasks/api_logger_tasks.rake"
    end
    
    generators do
      require "generators/api_logger/install/install_generator"
    end
  end
end
