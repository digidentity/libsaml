module Saml
  module ComplexTypes
    module AttributeType
      extend ActiveSupport::Concern
      include Saml::Base

      included do
        register_namespace "saml", Saml::SAML_NAMESPACE

        attribute :name, String, :tag => 'Name'
        attribute :format, String, tag: 'NameFormat'
        attribute :friendly_name, String, tag: 'FriendlyName'

        has_many :attribute_values, Saml::Elements::AttributeValue

        validates :name, :presence => true
      end

      def initialize(*args)
        options = args.extract_options!
        @attribute_values ||= []
        super(*(args << options))
      end

      def attribute_value
        warn '[DEPRECATED] please use #attribute_values'
        attribute_values.first.try(:content)
      end

      def attribute_value=(value)
        self.attribute_values << if value.is_a? String
          Saml::Elements::AttributeValue.new(content: value)
        else
          value
        end
      end

    end
  end
end
