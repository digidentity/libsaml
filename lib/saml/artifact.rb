module Saml
  class Artifact
    include ::HappyMapper

    TYPE_CODE       = "\000\004"
    END_POINT_INDEX = "\000\000"

    tag "Artifact"
    namespace 'samlp'

    content :artifact, String

    def initialize(artifact = nil)
      if artifact
        @artifact = artifact
      else
        source_id       = ::Digest::SHA1.digest(Saml.current_provider.entity_id.to_s)
        message_handle  = ::SecureRandom.random_bytes(20)
        @type_code      = TYPE_CODE
        @endpoint_index = END_POINT_INDEX
        @artifact   = Saml::Encoding.encode_64 [@type_code, @endpoint_index, source_id, message_handle].join
      end
    end

    def type_code
      decoded_value[0, 2]
    end

    def endpoint_index
      decoded_value[2, 2]
    end

    def source_id
      decoded_value[4, 20]
    end

    def message_handle
      decoded_value[24, 20]
    end

    def to_s
      artifact
    end

    private

    def decoded_value
      ::Base64.decode64(artifact)
    end
  end
end
