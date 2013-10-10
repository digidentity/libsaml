module Saml
  class Response
    include Saml::ComplexTypes::StatusResponseType

    tag "Response"
    has_many :assertions, Saml::Assertion, tag: "Assertion"
    has_many :encrypted_assertions, Saml::Elements::EncryptedAssertion, tag: "EncryptedAssertion"

    def authn_failed?
      !success? && status.status_code.authn_failed?
    end

    def request_denied?
      !success? && status.status_code.request_denied?
    end

    def no_authn_context?
      !success? && status.status_code.no_authn_context?
    end

    def assertion
      assertions.first
    end

    def assertion=(assertion)
      (self.assertions ||= []) << assertion
    end

    def encrypted_assertion
      encrypted_assertions.first
    end

    def encrypted_assertions=(encrypted_assertion)
      (self.encrypted_assertions ||= []) << encrypted_assertion
     end
  end
end
