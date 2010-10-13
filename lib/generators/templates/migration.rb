class <%= migration_class_name %> < ActiveRecord::Migration
  def self.up
    create_text_search_documents_table <%= Rails.application.config.make_text_search.table_name.inspect  %>
  end

  def self.down
    drop_table <%= Rails.application.config.make_text_search.table_name.inspect  %>
  end
end
