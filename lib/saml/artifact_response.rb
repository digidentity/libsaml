module Saml
  class ArtifactResponse
    include Saml::ComplexTypes::StatusResponseType

    tag "ArtifactResponse"

    has_one :response, Saml::Response
    has_one :authn_request, Saml::AuthnRequest

    def message
      authn_request || response
    end
  end
end
