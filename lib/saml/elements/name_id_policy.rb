module Saml
  module Elements
    class NameIdPolicy
      include Saml::Base

      tag 'NameIdPolicy'
      namespace 'samlp'

      attribute :allow_create, Boolean, tag: "AllowCreate"
      attribute :format, String, tag: "Format"

    end
  end
end
