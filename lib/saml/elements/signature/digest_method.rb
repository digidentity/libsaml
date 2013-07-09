module Saml
  module Elements
    class Signature
      class DigestMethod
        include Saml::Base

        tag "DigestMethod"
        namespace 'ds'

        attribute :algorithm, String, :tag => "Algorithm"

        def initialize(*args)
          @algorithm = "http://www.w3.org/2001/04/xmlenc#sha256"
          super(*args)
        end
      end
    end
  end
end
