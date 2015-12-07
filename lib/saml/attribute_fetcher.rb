module Saml
  module AttributeFetcher
    extend ActiveSupport::Concern

    included do
      def fetch_attribute(key)
        fetch_attribute_value(key).content
      end

      def fetch_attributes(key)
        fetch_attribute_values(key).map(&:content)
      end

      def fetch_attribute_value(key)
        fetch_attribute_values(key).first
      end

      def fetch_attribute_values(key)
        attributes.find_all { |attr| attr.name == key }.flat_map(&:attribute_values)
      end
    end
  end
end
