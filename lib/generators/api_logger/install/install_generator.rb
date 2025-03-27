require 'rails/generators'
require 'rails/generators/active_record'

module ApiLogger
  module Generators
    class InstallGenerator < Rails::Generators::Base
      include Rails::Generators::Migration

      source_root File.expand_path('templates', __dir__)

      def self.next_migration_number(dirname)
        ActiveRecord::Generators::Base.next_migration_number(dirname)
      end

      def copy_migration
        template(
          'create_api_logs.rb.tt',
          "db/migrate/#{next_migration_number}_create_#{ApiLogger.config.table_name}.rb"
        )
      end

      private

      def next_migration_number
        Time.now.utc.strftime("%Y%m%d%H%M%S")
      end
    end
  end
end
