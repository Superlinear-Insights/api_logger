namespace :api_logger do
  desc "Clean up logs older than a specified age (default: 30 days)"
  task clean: :environment do
    days = ENV['DAYS'] || 30
    table_name = ApiLogger.config.table_name
    model = ApiLogger.send(:get_model_class)

    deleted = model.where('created_at < ?', Time.now - days.to_i.days).delete_all
    puts "Deleted #{deleted} records from #{table_name} older than #{days} days"
  end
end
