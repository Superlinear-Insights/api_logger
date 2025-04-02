module ApiLogger
  class Configuration
    attr_accessor :table_name, :enabled, :use_middleware, :allowed_hosts, :exclude_hosts, :exclude_routes

    def initialize
      @table_name = 'api_logs'
      @enabled = true
      @use_middleware = true
      @allowed_hosts = ['services.mfcentral.com', 'uatservices.mfcentral.com']
      # backwards compatibility, to be removed in next release.
      @exclude_hosts = []
      @exclude_routes = []
    end

    def should_log_route?(path, host = nil)
      return false unless enabled && use_middleware
      return false unless host

      # Only log if host is in allowed list
      allowed_hosts.include?(host)
    end
  end
end
