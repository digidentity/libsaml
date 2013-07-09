module Saml
  module Elements
    class Signature
      class CanonicalizationMethod
        include Saml::Base

        tag "CanonicalizationMethod"
        namespace 'ds'

        attribute :algorithm, String, :tag => "Algorithm"

        def initialize(*args)
          @algorithm = "http://www.w3.org/2001/10/xml-exc-c14n#"
          super(*args)
        end
      end
    end
  end
end
