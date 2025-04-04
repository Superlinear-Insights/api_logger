require 'simplecov'
SimpleCov.start do
  add_filter '/spec/'
  add_filter '/vendor/'

  add_group 'Middleware', 'lib/api_logger/middleware.rb'
  add_group 'Configuration', 'lib/api_logger/configuration.rb'
end

require 'bundler/setup'
require 'api_logger'
require 'webmock/rspec'
require 'pry'

# Load support files
Dir[File.join(File.dirname(__FILE__), 'support', '**', '*.rb')].sort.each { |f| require f }

RSpec.configure do |config|
  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = '.rspec_status'

  # Disable RSpec exposing methods globally on `Module` and `main`
  config.disable_monkey_patching!

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end

  # Reset ApiLogger configuration before each test
  config.before do
    ApiLogger.configure do |c|
      c.enabled = true
      c.use_middleware = true
      c.allowed_hosts = []
    end
  end
end

# Configure WebMock
WebMock.disable_net_connect!(allow_localhost: true)
