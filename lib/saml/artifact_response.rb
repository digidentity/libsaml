module Saml
  class ArtifactResponse
    include Saml::ComplexTypes::StatusResponseType

    tag "ArtifactResponse"

    has_one :response, Saml::Response
  end
end
