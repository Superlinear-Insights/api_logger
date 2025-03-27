module ApiLogger
  class Configuration
    attr_accessor :table_name, :enabled, :use_middleware
    
    def initialize
      @table_name = 'api_logs'
      @enabled = true
      @use_middleware = true  # Enable middleware by default
    end
  end
end
