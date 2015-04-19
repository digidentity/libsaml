require 'happymapper'

module Saml
  module Base
    extend ActiveSupport::Concern
    
    included do
      include ::HappyMapper
      include ::ActiveModel::Validations

      extend HappyMapperClassMethods
      include HappyMapperInstanceMethods
      
      register_namespace 'saml2p', 'urn:oasis:names:tc:SAML:2.0:protocol'
      register_namespace 'saml2',  'urn:oasis:names:tc:SAML:2.0:assertion'
    end

    module HappyMapperInstanceMethods
      def initialize(attributes = {})
        attributes.each do |key, value|
          send("#{key}=", value) if respond_to?("#{key}=") && value.present?
        end
      end

      def from_xml=(bool)
        @from_xml = bool
      end

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
