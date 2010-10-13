
require "make-text-search/adapters/postgresql_ts"

module MakeTextSearch
  module ConnectionAdapterHelpers

    # Returns the MakeTextSearch adapter for the current connection
    def text_search_adapter
      @text_search_adapter ||=
        begin
          # TODO Use a list adapter
          if Adapters::PostgreSQL.is_available?(self)
            Adapters::PostgreSQL.new(self)
          else
            # TODO Generic implementation (for SQLite3, etc)
            raise NotImplementedError, "There is no adapter for #{self}"
          end
        end
    end

    # Create the text_search_documents table
    def create_text_search_documents_table(table_name)
      text_search_adapter.create_text_search_documents_table table_name
    end
  end

  module SchemaDumperHelpers #:nodoc:
    def self.included(cls)
      cls.alias_method_chain :table, :make_text_search
    end

    def table_with_make_text_search(table, stream)
      if table.to_s == Rails.application.config.make_text_search.table_name.to_s
        stream.puts "  create_text_search_documents_table #{table.inspect}"
      else
        table_without_make_text_search(table, stream)
      end

      stream
    end
  end
end
