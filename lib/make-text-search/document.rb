module MakeTextSearch
  class Document < ActiveRecord::Base
    set_table_name { Rails.application.config.make_text_search.table_name }

    belongs_to :record, :polymorphic => true
  end
end
