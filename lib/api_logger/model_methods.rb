module ApiLogger
  module ModelMethods
    extend ActiveSupport::Concern

    included do
      # Scopes
      scope :errors, -> { where.not(error_message: nil) }
      scope :successful, -> { where(error_message: nil) }
      scope :by_endpoint, ->(endpoint) { where(endpoint: endpoint) }
      scope :recent, -> { order(created_at: :desc) }
      scope :older_than, ->(days) { where('created_at < ?', days.days.ago) }

      # Validations
      validates :endpoint, presence: true
    end

    # Instance methods
    def successful?
      error_message.nil?
    end

    def response_time
      (updated_at - created_at).round(2)
    end

    def response_code_type
      case response_status
      when 200..299 then :success
      when 300..399 then :redirect
      when 400..499 then :client_error
      when 500..599 then :server_error
      else :unknown
      end
    end

    # Class methods
    module ClassMethods
      def cleanup_old_logs(days = 30)
        older_than(days).delete_all
      end

      def endpoints_with_errors
        errors.distinct.pluck(:endpoint)
      end

      def error_rate_by_endpoint
        total = group(:endpoint).count
        errors = group(:endpoint).where.not(error_message: nil).count
        
        total.map do |endpoint, count|
          error_count = errors[endpoint] || 0
          rate = (error_count.to_f / count * 100).round(2)
          [endpoint, rate]
        end.to_h
      end
    end
  end
end 