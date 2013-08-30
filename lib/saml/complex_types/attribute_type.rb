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
        element :attribute_value, String, :namespace => 'saml', :tag => "AttributeValue"

        validates :name, :presence => true
      end

      def initialize(*args)
        options = args.extract_options!
        super(*(args << options))
      end
    end
  end
end
