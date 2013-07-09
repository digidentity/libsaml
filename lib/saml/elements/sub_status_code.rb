module Saml
  module Elements
    class SubStatusCode
      include Saml::Base

      tag "StatusCode"
      namespace 'samlp'

      attribute :value, String, :tag => "Value"

      validates :value, :presence => true, :inclusion => SubStatusCodes::ALL
    end
  end
end
