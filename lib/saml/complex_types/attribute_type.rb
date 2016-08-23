module Saml
  module ComplexTypes
    module AttributeType
      extend ActiveSupport::Concern
      include Saml::Base

      included do
        register_namespace "saml", Saml::SAML_NAMESPACE
        register_namespace 'ext',  Saml::ATTR_EXT_NAMESPACE

        attribute :name, String, :tag => 'Name'
        attribute :format, String, tag: 'NameFormat'
        attribute :friendly_name, String, tag: 'FriendlyName'

        attribute :original_issuer, String, tag: 'ext:OriginalIssuer'
        attribute :last_modified, Time, tag: 'ext:LastModified', on_save: lambda { |val| val.utc.xmlschema if val.present? }

        has_many :attribute_values, Saml::Elements::AttributeValue

        validates :name, :presence => true
      end

      def initialize(*args)
        options = args.extract_options!
        @attribute_values ||= []
        super(*(args << options))
      end

      def attribute_value
        warn '[DEPRECATED] `attribute_value` please use #attribute_values'
        attribute_values.first.try(:content)
      end

      def attribute_value=(value)
        attribute_value = if value.is_a? String
          Saml::Elements::AttributeValue.new(content: value)
        else
          value
        end
        self.attribute_values = [attribute_value]
      end

    end
  end
end
