require 'saml/elements/key_info'

module Saml
  module Elements
    class KeyDescriptor
      include Saml::Base

      module UseTypes
        SIGNING    = "signing"
        ENCRYPTION = "encryption"
        ALL        = [SIGNING, ENCRYPTION, nil]
      end

      tag 'KeyDescriptor'
      namespace 'md'

      attribute :use, String, tag: "use"

      has_one :key_info, KeyInfo

      validates :use, inclusion: UseTypes::ALL
      validates :certificate, presence: true

      def certificate
        key_info.try(:x509Data).try(:x509certificate)
      end

      def certificate=(cert)
        self.key_info = KeyInfo.new(cert)
      end

    end
  end
end
