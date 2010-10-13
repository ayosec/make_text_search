module MakeTextSearch
  module Adapters
    class PostgreSQL

      attr_reader :connection

      def self.is_available?(connection)
        begin
          connection.select_one("select to_tsquery('test') as query").has_key?("query")
        rescue ActiveRecord::StatementInvalid
          false
        end
      end

      def initialize(connection)
        @connection = connection
      end

      # Schema actions

      def create_text_search_documents_table(table_name)
        connection.execute %[CREATE TABLE #{table_name} (record_type varchar(300) NOT NULL, record_id integer NOT NULL, language varchar(20), document tsvector)]
        connection.execute %[CREATE INDEX #{table_name}_idx ON #{table_name} USING gin(document)]
      end


      # Document actions

      def quote(value)
        @connection.quote value
      end

      def update_document(record)

        record_class = record.class
        return if record_class.text_search_fields.empty?

        table_name = Rails.application.config.make_text_search.table_name
        record_type = quote record_class.name
        record_id = quote record.id
        language = quote record.text_search_language

        document = "to_tsvector(#{language}, #{quote record.text_search_build_document})"

        if connection.select_value("SELECT count(*) FROM #{table_name} WHERE #{_where_record record}").to_i == 0
          connection.insert(%[INSERT INTO #{table_name}
                              (record_type, record_id, language, document)
                             VALUES
                              (#{record_type}, #{record_id}, #{language}, #{document})])
        else
          connection.update(%[UPDATE #{table_name} SET document = #{document} WHERE #{_where_record record}])
        end
      end

      def remove_document(record)
        connection.delete "DELETE FROM #{Rails.application.config.make_text_search.table_name} WHERE #{_where_record record}"
      end

      def _where_record(record)
        "record_type = #{quote record.class.name} AND record_id = #{quote record.id}"
      end

    end
  end
end