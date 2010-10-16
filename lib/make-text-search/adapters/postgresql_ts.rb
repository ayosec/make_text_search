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
        connection.execute %[CREATE TABLE #{table_name} (id serial primary key, record_type varchar(300) NOT NULL, record_id integer NOT NULL, language varchar(20), document tsvector)]
        connection.execute %[CREATE INDEX #{table_name}_idx ON #{table_name} USING gin(document)]
      end

      # Document actions

      def quote(value)
        @connection.quote value
      end

      def update_document(record)

        record_class = record.class
        return if record_class.text_search_fields.empty?

        record_type, record_id = record.class, record.id
        unless document = Document.find_by_record_type_and_record_id(record_type, record_id)
          document = Document.new
          document.record = record
          document.save!
        end

        language = record.text_search_language
        quoted_language = record.connection.quote(language)
        ts_vector = "to_tsvector(#{language ? "#{quoted_language}, " : ""}#{record.connection.quote record.text_search_build_document})"
        Document.update_all "language = #{quoted_language}, document = #{ts_vector}", ["id = ?", document.id]
      end

      def remove_document(record)
        Document.delete_all ["record_type = ? AND record_id = ?", record.class, record.id]
      end

      # Query actions
      def scope_search_text(model, query, language = Rails.application.config.make_text_search.default_language)
        document_query = Document.select("record_id").where("record_type = :type AND document @@ to_tsquery(#{language ? ":language, " : ""}:query)", :type => model.name, :language => language, :query => query)
        model.where %[#{model.table_name}.id IN (#{document_query.to_sql})]
      end

    end
  end
end
