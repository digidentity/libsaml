module Saml
  module Elements
    class Audience
      include Saml::Base

      tag 'Audience'
      namespace 'saml'

      content :value, String
    end
  end
end
