require 'rails/generators/active_record'

module TextSearch
  class MigrationGenerator < ActiveRecord::Generators::Base
    argument :name, :type => :string, :default => "add_text_search_documents_table"

    source_root File.join(File.dirname(__FILE__), "templates")

    def create_migration_file
      migration_template "migration.rb", "db/migrate/#{file_name}.rb"
    end

  end
end

