module Saml
  module Elements
    class Status
      include Saml::Base

      tag "Status"
      namespace 'samlp'

      has_one :status_code, Saml::Elements::StatusCode

      validates :status_code, :presence => true

    end
  end
end
