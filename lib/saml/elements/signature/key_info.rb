module Saml
  module Elements
    class Signature
      class KeyInfo
        include Saml::Base

        tag "KeyInfo"
        namespace 'ds'

        element :key_name, String, :namespace => 'ds', :tag => "KeyName"
      end
    end
  end
end