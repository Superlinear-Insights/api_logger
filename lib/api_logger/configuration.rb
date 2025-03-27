module ApiLogger
  class Configuration
    attr_accessor :table_name, :enabled
    
    def initialize
      @table_name = 'api_logs'
      @enabled = true
    end
  end
end
