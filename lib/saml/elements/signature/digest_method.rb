module Saml
  module Elements
    class Signature
      class DigestMethod
        include Saml::Base

        tag "DigestMethod"
        namespace 'ds'

        attribute :algorithm, String, :tag => "Algorithm"

        def initialize(*args)
          @algorithm = Saml::Config.digest_algorithm
          super(*args)
        end
      end
    end
  end
end
