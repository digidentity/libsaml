module Saml
  module Elements
    class Status
      include Saml::Base

      tag "Status"
      namespace 'samlp'

      has_one :status_code, Saml::Elements::StatusCode
      has_one :status_detail, Saml::Elements::StatusDetail

      element :status_message, String, tag: 'StatusMessage'

      validates :status_code, :presence => true

    end
  end
end
