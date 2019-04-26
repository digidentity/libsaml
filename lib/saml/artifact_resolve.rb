module Saml
  class ArtifactResolve
    include Saml::ComplexTypes::RequestAbstractType

    tag "ArtifactResolve"
    has_one :artifact, Saml::Artifact

    validates :artifact, presence: true

    def initialize(*args)
      options   = args.extract_options!
      artifact  = options.delete(:artifact)
      @artifact = artifact.is_a?(Saml::Artifact) ? artifact : Saml::Artifact.new(artifact)
      super(*(args << options))
    end
  end
end
