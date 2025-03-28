module ApiLogger
  class Configuration
    attr_accessor :table_name, :enabled, :use_middleware, :exclude_routes, :exclude_hosts

    def initialize
      @table_name = 'api_logs'
      @enabled = true
      @use_middleware = true
      @exclude_routes = []
      @exclude_hosts = []
    end

    def should_log_route?(path, host = nil)
      return false unless enabled && use_middleware

      # Skip if host matches excluded hosts
      return false if host && exclude_hosts.any? { |excluded_host| path_matches_pattern?(host, excluded_host) }

      # Skip if path matches excluded routes
      !exclude_routes.any? { |pattern| path_matches_pattern?(path, pattern) }
    end

    private

    def path_matches_pattern?(path, pattern)
      case pattern
      when String
        path.include?(pattern)
      when Regexp
        pattern.match?(path)
      else
        false
      end
    end
  end
end
