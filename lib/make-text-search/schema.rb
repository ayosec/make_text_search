module MakeTextSearch
  module ConnectionAdapterHelpers

    # Returns true if the database has ts_ support in PostgreSQL
    def has_text_search_for_postgresql?
      @has_text_search_for_postgresql ||=
        begin
          select_one("select to_tsquery('test') as fn").has_key?("fn")
        rescue ActiveRecord::StatementInvalid
          false
        end
    end

    def create_text_search_documents_table(table_name)
      if has_text_search_for_postgresql?
        execute %[CREATE TABLE #{table_name} (record_type varchar(300) NOT NULL, record_id integer NOT NULL, language varchar(20), document tsvector)]
        execute %[CREATE INDEX #{table_name}_idx ON #{table_name} USING gin(document)]
      else
        # TODO Generic implementation (for SQLite3, etc)
      end
    end
  end

  module SchemaDumperHelpers
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
