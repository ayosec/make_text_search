class <<MakeTextSearch

  def update_document(record)

    # TODO use has_text_search_for_postgresql? to implement all the backends

    record_class = record.class
    return if record_class.text_search_fields.empty?

    table_name = Rails.application.config.make_text_search.table_name
    db_connection = record.class.connection
    record_type = db_connection.quote record_class.name
    record_id = db_connection.quote record.id
    language = db_connection.quote record.text_search_language

    document = "to_tsvector(#{language}, #{db_connection.quote record.text_search_build_document})"

    if db_connection.select_value("SELECT count(*) FROM #{table_name} WHERE #{_where_record record}").to_i == 0
      db_connection.insert(%[INSERT INTO #{table_name}
                              (record_type, record_id, language, document)
                             VALUES
                              (#{record_type}, #{record_id}, #{language}, #{document})])
    else
      db_connection.update(%[UPDATE #{table_name} SET document = #{document} WHERE #{_where_record record}])
    end
  end

  def remove_document(record, db_connection = ActiveRecord::Base.connection)
    db_connection.delete "DELETE FROM #{Rails.application.config.make_text_search.table_name} WHERE #{_where_record record}"
  end

  def _where_record(record, db_connection = ActiveRecord::Base.connection)
    "record_type = #{db_connection.quote record.class.name} AND record_id = #{db_connection.quote record.id}"
  end

end
