module Saml
  class AuthnRequest
    include Saml::ComplexTypes::RequestAbstractType

    attr_accessor :xml_value

    tag 'AuthnRequest'
    attribute :force_authn, Boolean, :tag => "ForceAuthn"
    attribute :is_passive, Boolean, :tag => "IsPassive"
    attribute :assertion_consumer_service_index, Integer, :tag => "AssertionConsumerServiceIndex"
    attribute :assertion_consumer_service_url, String, :tag => "AssertionConsumerServiceURL"
    attribute :attribute_consuming_service_index, Integer, :tag => "AttributeConsumingServiceIndex"
    attribute :protocol_binding, String, :tag => "ProtocolBinding"
    attribute :provider_name, String, :tag => "ProviderName"

    has_one :requested_authn_context, Saml::Elements::RequestedAuthnContext
    has_one :scoping, Saml::Elements::Scoping
    has_one :name_id_policy, Saml::Elements::NameIdPolicy

    validates :force_authn, :inclusion => [true, false, nil]
    validates :assertion_consumer_service_index, :numericality => true, :if => lambda { |val|
      val.assertion_consumer_service_index.present?
    }

    validate :check_assertion_consumer_service

    def assertion_url
      return assertion_consumer_service_url if assertion_consumer_service_url
      provider.assertion_consumer_service_url(assertion_consumer_service_index) if assertion_consumer_service_index
    end

    def initialize(*args)
      options = args.extract_options!
      name_id_format = options.delete(:name_id_format)
      allow_create = options.delete(:allow_create) || true
      super(*(args << options))
      @name_id_policy = Saml::Elements::NameIdPolicy.new(format: name_id_format, allow_create: allow_create) unless name_id_format.nil?
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
