module Saml
  class Response
    include Saml::ComplexTypes::StatusResponseType

    tag "Response"
    has_many :assertions, Saml::Assertion
    has_many :encrypted_assertions, Saml::Elements::EncryptedAssertion

    def authn_failed?
      !success? && status.status_code.authn_failed?
    end

    def request_denied?
      !success? && status.status_code.request_denied?
    end

    def no_authn_context?
      !success? && status.status_code.no_authn_context?
    end

    def encrypt_assertions(certificate)
      @encrypted_assertions = []
      assertions.each do |assertion|
        assertion_xml = assertion.is_a?(Assertion) ? assertion.to_xml : assertion.to_s

        @encrypted_assertions << Saml::Util.encrypt_assertion(assertion_xml, certificate)
      end
      assertions.clear
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

    def encrypted_assertion=(encrypted_assertion)
      (self.encrypted_assertions ||= []) << encrypted_assertion
     end
  end
end
