# API Logger

A simple gem for logging API requests and responses in Rails applications. It automatically logs all outbound HTTP requests with zero configuration needed.

## Features

- **Automatic Request Logging**: Automatically logs all outbound HTTP requests made using Net::HTTP
- **Zero Configuration**: Works out of the box with sensible defaults
- **Flexible Control**: Easy to enable/disable logging through configuration
- **Comprehensive Logging**: Captures request parameters, response bodies, status codes, and errors
- **Database Storage**: All logs are stored in your database for easy querying
- **Rails Integration**: Seamlessly integrates with your Rails application

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'api_logger', github: 'Superlinear-Insights/api_logger'
```

And then execute:

```bash
$ bundle install
$ rails generate api_logger:install
$ rails db:migrate
```

## Configuration

By default, the gem works without any configuration. However, you can customize its behavior by creating an initializer (`config/initializers/api_logger.rb`):

```ruby
ApiLogger.configure do |config|
  # The database table where logs will be stored
  config.table_name = 'api_logs'  # default

  # Enable/disable all logging functionality
  config.enabled = true  # default

  # Enable/disable automatic request logging via middleware
  config.use_middleware = true  # default
end
```

### Configuration Options

- `table_name`: The name of the database table where logs will be stored
- `enabled`: Master switch to enable/disable all logging functionality
- `use_middleware`: Controls automatic logging of HTTP requests
  - When `true`: All outbound HTTP requests are automatically logged
  - When `false`: Only manual logging via `ApiLogger.log` is available

### Configuration Combinations

Here's what happens with different configuration combinations:

```ruby
# 1. Everything enabled (default)
ApiLogger.configure do |config|
  config.enabled = true
  config.use_middleware = true
end
# Outcome: Both automatic and manual logging work

# 2. Only manual logging
ApiLogger.configure do |config|
  config.enabled = true
  config.use_middleware = false
end
# Outcome: Only ApiLogger.log calls will work, automatic logging disabled

# 3. Everything disabled
ApiLogger.configure do |config|
  config.enabled = false  # This is the master switch
  config.use_middleware = true  # This setting doesn't matter when enabled = false
end
# Outcome: All logging is disabled, both ApiLogger.log calls and automatic logging will be silently ignored
```

## Usage

### Automatic Request Logging

With default configuration, any HTTP request made using Net::HTTP will be automatically logged:

```ruby
# These requests will be automatically logged
uri = URI('https://api.example.com/users')
response = Net::HTTP.get_response(uri)

# POST request
http = Net::HTTP.new(uri.host, uri.port)
http.use_ssl = true
request = Net::HTTP::Post.new(uri.path, 'Content-Type' => 'application/json')
request.body = { name: 'John' }.to_json
response = http.request(request)
```

### Disabling Automatic Logging

If you want to disable automatic logging while keeping the ability to log manually:

```ruby
# In config/initializers/api_logger.rb
ApiLogger.configure do |config|
  config.use_middleware = false  # Disables automatic logging
  config.enabled = true         # Keeps manual logging available
end
```

### Manual Logging

You can also log requests manually when needed:

```ruby
ApiLogger.log(
  endpoint: '/api/users',
  request_params: { user_id: 123 },
  response_body: { name: 'John' },
  response_status: 200,
  error_message: nil  # optional, for failed requests
)
```

### Accessing Logs

Logs are accessible through the `ApiLog` model:

```ruby
# Get the most recent log
ApiLog.last

# Get recent logs
ApiLog.order(created_at: :desc)

# Find logs for a specific endpoint
ApiLog.where(endpoint: '/api/users')

# Get failed requests (status >= 400)
ApiLog.where('response_status >= ?', 400)

# Get successful requests
ApiLog.where('response_status < ?', 400)
```

### Log Data Structure

Each log entry contains:
- `endpoint`: The API endpoint that was called
- `request_params`: Parameters sent with the request (stored as JSON)
- `response_body`: The response received (stored as JSON)
- `response_status`: HTTP status code of the response
- `error_message`: Error message (for failed requests)
- `created_at`: When the log was created
- `updated_at`: When the log was last updated

## Maintenance

To clean up old logs, use the provided rake task:

```bash
# Clean logs older than 30 days (default)
rails api_logger:clean

# Clean logs older than N days
DAYS=7 rails api_logger:clean
```
