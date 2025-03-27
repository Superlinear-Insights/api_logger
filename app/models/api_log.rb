class ApiLog < ActiveRecord::Base
  # Your custom methods here
  scope :last_hour, -> { where('created_at > ?', 1.hour.ago) }
  
  def formatted_response
    JSON.pretty_generate(response_body) rescue response_body.to_s
  end

  def duration_ms
    ((updated_at - created_at) * 1000).round(2)
  end

  def self.error_summary
    errors.group(:endpoint).count
  end
end 