module Saml
  class ArtifactResolve
    include Saml::ComplexTypes::RequestAbstractType

    tag "ArtifactResolve"
    has_one :artifact, Saml::Artifact

    validates :artifact, :presence => true
  end
end
