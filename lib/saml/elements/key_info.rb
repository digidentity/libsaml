require 'saml/elements/key_info/x509_data'

module Saml
  module Elements
    class KeyInfo
      include Saml::Base

      register_namespace 'ds', Saml::XML_DSIG_NAMESPACE
      namespace 'ds'
      tag 'KeyInfo'

      element :key_name, String, :namespace => 'ds', :tag => "KeyName"

      has_one :x509Data, X509Data

      validates :x509Data, :presence => true

      def initialize(cert = nil)
        if cert
          self.x509Data = X509Data.new(cert)
        end
        if self.x509Data && self.x509Data.x509certificate && Saml::Config.generate_key_name
          self.key_name = Digest::SHA1.hexdigest(self.x509Data.x509certificate.to_der)
        end
      end
    end
  end
end
