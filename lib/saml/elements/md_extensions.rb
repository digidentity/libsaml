module Saml
  module Elements
    class MDExtensions
      include Saml::Base
      include Saml::XMLHelpers

      tag "Extensions"
      namespace "md"

      has_one :entity_attributes, Saml::Elements::EntityAttributes
    end
  end
end
