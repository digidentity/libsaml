module Saml
  module Elements
    class AudienceRestriction
      include Saml::Base

      tag 'AudienceRestriction'
      namespace 'saml'

      has_many :audiences, Saml::Elements::Audience

      def audience
        Array(audiences).first.try(:value)
      end

      def audience=(value)
        self.audiences = [ Saml::Elements::Audience.new(value: value) ]
      end
    end
  end
end
