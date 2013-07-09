module Saml
  module Elements
    class RequestedAuthnContext

      module ComparisonTypes
        EXACT   = 'exact'
        MINIMUM = 'minimum'
        MAXIMUM = 'maximum'
        BETTER  = 'better'
        ALL     = [EXACT, MINIMUM, MAXIMUM, BETTER, nil]
      end

      include Saml::ClassRefs

      include Saml::Base

      tag 'RequestedAuthnContext'
      namespace 'samlp'

      attribute :comparison, String, :tag => "Comparison"

      element :authn_context_class_ref, String, :namespace => 'saml', :tag => "AuthnContextClassRef"

      validates :authn_context_class_ref, :presence => true, :inclusion => ALL_CLASS_REFS
      validates :comparison, :inclusion => ComparisonTypes::ALL
    end
  end
end
