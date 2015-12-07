module Saml
  module Elements
    class SAMLPExtensions
      include Saml::Base
      include Saml::XMLHelpers
      include Saml::AttributeFetcher

      tag "Extensions"
      namespace "samlp"

      has_many :attributes, Saml::Elements::Attribute
    end
  end
end
