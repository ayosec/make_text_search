require 'test_helper'

class SchemaTest < ActiveSupport::TestCase
  test "schema has to include the call for create_text_search_documents_table" do
    assert_match /^\s*create_text_search_documents_table/, Rails.root.join("db/schema.rb").read
  end

  test "documents table has to be created" do
    assert_operator ActiveRecord::Base.connection.tables, "include?", Rails.application.config.make_text_search.table_name
  end
end
