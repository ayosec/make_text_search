module MakeTextSearch

  ActiveSupport.on_load(:active_record) do
    require 'make-text-search/models'
    require 'make-text-search/schema'
    require 'make-text-search/filters'
    require 'make-text-search/document'

    include ModelHelpers
    class ActiveRecord::ConnectionAdapters::AbstractAdapter; include ConnectionAdapterHelpers; end
    class ActiveRecord::SchemaDumper; include SchemaDumperHelpers; end
  end

  class Railtie < ::Rails::Railtie
    config.make_text_search = ActiveSupport::OrderedOptions.new
    config.make_text_search.table_name = "text_search_documents"
    config.make_text_search.default_language = nil

    generators do
      load "generators/migration.rb"
    end
  end
end
