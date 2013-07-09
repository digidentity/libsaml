module Saml
  module Elements
    class AudienceRestriction
      include Saml::Base

      tag "AudienceRestriction"
      namespace 'saml'

      element :audience, String, :tag => "Audience"
    end
  end
end
