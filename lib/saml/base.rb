require 'happymapper'

module Saml
  module Base
    extend ActiveSupport::Concern

    included do
      include ::HappyMapper
      include ::ActiveModel::Validations

      attr_accessor :xml_value
      has_xml_content

      extend HappyMapperClassMethods
      include HappyMapperInstanceMethods
    end

    module HappyMapperInstanceMethods
      def initialize(attributes = {})
        attributes.each do |key, value|
          send("#{key}=", value) if respond_to?("#{key}=") && value.present?
        end
      end

      attr_writer :from_xml

      def from_xml?
        @from_xml
      end
    end

    module HappyMapperClassMethods
      def parse(xml, options = {})
        if xml.is_a?(String)
          ActiveSupport::XmlMini_REXML.parse(xml)
        end

        object = super
        if object.is_a?(Array)
          object.map { |x| x.from_xml = true }
        elsif object
          object.from_xml = true
        end
        object
      rescue Nokogiri::XML::SyntaxError, REXML::ParseException => e
        raise Saml::Errors::UnparseableMessage.new(e.message)
      rescue TypeError => e
        raise Saml::Errors::UnparseableMessage.new(e.message)
      rescue NoMethodError => e
        raise Saml::Errors::UnparseableMessage.new(e.message)
      end
    end
  end
end
