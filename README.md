# API Logger

A simple yet powerful gem for logging API requests and responses in Rails applications. It automatically stores API interactions in your database with minimal setup.

## Features

- Log API requests and responses with a single method call
- Automatic JSON handling for request parameters and response bodies
- Configurable table name

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'api_logger'
```

And then execute:

```bash
$ bundle install
$ rails generate api_logger:install
$ rails db:migrate
```

## Basic Usage

Simply call the logger in your API client code:

```ruby
def fetch_user_data(user_id)
  response = api_client.get("/users/#{user_id}")
  
  ApiLogger.log(
    endpoint: "/users/#{user_id}",
    request_params: { user_id: user_id },
    response_body: response.body,
    response_status: response.status,
    error_message: response.error? ? response.error_message : nil
  )
  
  response.body
end
```

## Configuration

Create an initializer (`config/initializers/api_logger.rb`):

```ruby
ApiLogger.configure do |config|
  config.table_name = 'api_logs' # default
  config.enabled = true # default
end
```

## Database Schema

The gem creates a table with the following structure:

```ruby
create_table :api_logs do |t|
  t.string :endpoint, null: false
  t.jsonb :request_params
  t.jsonb :response_body
  t.integer :response_status
  t.string :error_message
  t.timestamps
end

add_index :api_logs, :endpoint
add_index :api_logs, :created_at
add_index :api_logs, :response_status
```

## Extending Functionality

While the gem creates the model dynamically, you can add your own methods by creating a model file in your application:

```ruby
# app/models/api_log.rb
class ApiLog < ActiveRecord::Base
  # Add your custom methods here
  scope :recent, -> { order(created_at: :desc) }
  
  def formatted_response
    JSON.pretty_generate(response_body) rescue response_body.to_s
  end
end
```
