module MakeTextSearch

  module ModelHelpers
    extend ActiveSupport::Concern

    included do
      class_inheritable_array :text_search_fields
      self.text_search_fields = []

      after_save :text_search_update_document
      after_destroy :text_search_remove_document
    end

    module ClassMethods
      def has_text_search(*fields)
        options = fields.extract_options!
        #options.assert_valid_keys :filter

        fields.each do |field|
          self.text_search_fields.push([field, options])
        end
      end

      def search_text(query)
        #where "#{table_name}.id IN (#{MakeTextSearch.})"
        where MakeTextSearch.build_condition(self, query)
      end
    end

    def text_search_update_document
      if not self.class.text_search_fields.empty?
        self.class.connection.text_search_adapter.update_document self
      end
    end

    def text_search_remove_document
      if not self.class.text_search_fields.empty?
        self.class.connection.text_search_adapter.remove_document self
      end
    end

    def text_search_language
      Rails.application.config.make_text_search.default_language
    end

    def text_search_build_document
      # TODO filters
      self.class.text_search_fields.map {|ts_field| send(ts_field[0]).try(:to_s) }.compact.join(" ")
    end
  end
end
