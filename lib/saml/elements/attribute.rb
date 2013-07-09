module Saml
  module Elements
    class Attribute
      include Saml::Base

      tag "Attribute"
      register_namespace 'saml', Saml::SAML_NAMESPACE
      namespace 'saml'

      attribute :name, String, :tag => 'Name'
      element :attribute_value, String, :namespace => 'saml', :tag => "AttributeValue"
      
      validates :name, :presence => true
      
      def initialize(*args)
        options = args.extract_options!
        super(*(args << options))
      end
      
    end
  end
end