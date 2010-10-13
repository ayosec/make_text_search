class <<MakeTextSearch
  def build_condition(model, query)
    # TODO use has_text_search_for_postgresql? to implement all the backends

    db_connection =  model.connection
    %[#{model.table_name}.id IN (SELECT record_id FROM #{Rails.application.config.make_text_search.table_name} WHERE record_type = #{db_connection.quote model.name} AND document @@ to_tsquery(#{db_connection.quote query}))]
  end
end
