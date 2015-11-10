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

    def unknown_principal?
      !success? && status.status_code.unknown_principal?
    end

    def encrypt_assertions(certificate)
      @encrypted_assertions = []
      assertions.each do |assertion|
        @encrypted_assertions << Saml::Util.encrypt_assertion(assertion, certificate)
      end
      assertions.clear
    end

    def decrypt_assertions(private_key)
      @assertions ||= []
      encrypted_assertions.each do |encrypted_assertion|
        @assertions << Saml::Util.decrypt_assertion(encrypted_assertion, private_key)
      end
      encrypted_assertions.clear
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
