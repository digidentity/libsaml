module Saml
  module Elements
    class AudienceRestriction
      include Saml::Base

      tag 'AudienceRestriction'
      namespace 'saml'

      has_many :audiences, String, tag: 'Audience'

      def audience
        Array(audiences).first
      end

      def audience=(audience)
        self.audiences = [audience]
      end
    end
  end
end
