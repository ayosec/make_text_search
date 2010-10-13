module MakeTextSearch

  ActiveSupport.on_load(:active_record) do
    require 'make-text-search/schema'
    class ActiveRecord::ConnectionAdapters::AbstractAdapter
      include MakeTextSearch::ConnectionAdapterHelpers
    end

    class ActiveRecord::SchemaDumper
      include MakeTextSearch::SchemaDumperHelpers
    end

  end

  class Railtie < ::Rails::Railtie
    config.make_text_search = ActiveSupport::OrderedOptions.new
    config.make_text_search.table_name = "text_search_documents"

    generators do
      load "generators/migration.rb"
    end
  end
end
