module Saml
  class AuthnRequest
    include Saml::ComplexTypes::RequestAbstractType

    tag 'AuthnRequest'
    attribute :force_authn, Boolean, :tag => "ForceAuthn"
    attribute :assertion_consumer_service_index, Integer, :tag => "AssertionConsumerServiceIndex"
    attribute :assertion_consumer_service_url, String, :tag => "AssertionConsumerServiceURL"
    attribute :attribute_consuming_service_index, Integer, :tag => "AttributeConsumingServiceIndex"
    attribute :protocol_binding, String, :tag => "ProtocolBinding"
    attribute :provider_name, String, :tag => "ProviderName"

    has_one :requested_authn_context, Saml::Elements::RequestedAuthnContext

    validates :force_authn, :inclusion => [true, false, nil, "1", "0"]
    validates :assertion_consumer_service_index, :numericality => true, :if => "assertion_consumer_service_index.present?"

    validate :check_assertion_consumer_service

    def assertion_url
      return assertion_consumer_service_url if assertion_consumer_service_url
      provider.assertion_consumer_service_url(assertion_consumer_service_index) if assertion_consumer_service_index
    end

    private

    def check_assertion_consumer_service
      if assertion_consumer_service_index.present?
        errors.add(:assertion_consumer_service_url, :must_be_blank) if @assertion_consumer_service_url.present?
        errors.add(:protocol_binding, :must_be_blank) if protocol_binding.present?
      end
    end
  end
end
