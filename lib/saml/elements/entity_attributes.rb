module Saml
  module Elements
    class EntityAttributes
      include Saml::Base
      include Saml::XMLHelpers

      register_namespace "mdattr", Saml::MD_ATTR_NAMESPACE

      tag "EntityAttributes"
      namespace "mdattr"

      has_many :attributes, Saml::Elements::Attribute
    end
  end
end
