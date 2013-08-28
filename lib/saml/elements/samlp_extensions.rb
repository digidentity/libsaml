module Saml
  module Elements
    class SAMLPExtensions
      include Saml::Base
      include Saml::XMLHelpers

      tag "Extensions"
      namespace "samlp"

      has_many :attributes, Saml::Elements::Attribute
    end
  end
end
