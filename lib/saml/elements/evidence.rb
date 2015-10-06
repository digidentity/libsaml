module Saml
  module Elements
    class Evidence
      include HappyMapper
      include Saml::Base
      include Saml::ComplexTypes::EvidenceType

      tag 'Evidence'
    end
  end
end
