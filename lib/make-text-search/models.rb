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
        options.assert_valid_keys :filter

        if options[:filter]
          options[:filter] = [options[:filter]].flatten.map! {|filter_name| "make_text_search/#{filter_name}_filter".camelize.constantize }
        end

        fields.each do |field|
          self.text_search_fields.push([field, options])
        end
      end

      def search_text(query)
        connection.text_search_adapter.scope_search_text(self, query)
      end
    end

    def text_search_update_document
      if not self.class.text_search_fields.blank?
        self.class.connection.text_search_adapter.update_document self
      end
    end

    def text_search_remove_document
      if not self.class.text_search_fields.blank?
        self.class.connection.text_search_adapter.remove_document self
      end
    end

    def text_search_language
      Rails.application.config.make_text_search.default_language
    end

    def text_search_build_document
      self.class.text_search_fields.map do |ts_field|
        field_name, options = ts_field

        if value = send(field_name)
          value = value.to_s

          if filters = options[:filter]
            filters.each {|f| value = f.apply_filter(self, value) }
          end

          value
        end
      end.compact.join(" ")
    end
  end
end
