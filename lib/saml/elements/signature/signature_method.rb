module Saml
  module Elements
    class Signature
      class SignatureMethod
        include Saml::Base

        tag "SignatureMethod"
        namespace 'ds'

        attribute :algorithm, String, tag: "Algorithm"

        def initialize(*args)
          @algorithm = Saml::Config.signature_algorithm
          super(*args)
        end
      end
    end
  end
end
