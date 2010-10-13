module MakeTextSearch

  ActiveSupport.on_load(:active_record) do
    require 'make-text-search/models'
    require 'make-text-search/query'
    require 'make-text-search/schema'

    include ModelHelpers
    class ActiveRecord::ConnectionAdapters::AbstractAdapter; include ConnectionAdapterHelpers; end
    class ActiveRecord::SchemaDumper; include SchemaDumperHelpers; end
  end

  class Railtie < ::Rails::Railtie
    config.make_text_search = ActiveSupport::OrderedOptions.new
    config.make_text_search.table_name = "text_search_documents"
    config.make_text_search.default_language = "english"

    generators do
      load "generators/migration.rb"
    end
  end
end
