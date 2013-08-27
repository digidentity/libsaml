module Saml
  module Elements
    class Extensions
      include Saml::Base
      include Saml::XMLHelpers

      tag "Extensions"
      namespace "samlp"

      has_one :entity_attributes, Saml::Elements::EntityAttributes
    end
  end
end
