module Saml
  module Elements
    class Evidence
      include XmlMapper
      include Saml::Base
      include Saml::ComplexTypes::EvidenceType

      tag 'Evidence'
    end
  end
end
