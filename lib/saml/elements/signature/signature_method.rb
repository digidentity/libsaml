module Saml
  module Elements
    class Signature
      class SignatureMethod
        include Saml::Base

        tag "SignatureMethod"
        namespace 'ds'

        attribute :algorithm, String, :tag => "Algorithm"

        def initialize(*args)
          @algorithm = "http://www.w3.org/2001/04/xmldsig-more#rsa-sha256"
          super(*args)
        end
      end
    end
  end
end
