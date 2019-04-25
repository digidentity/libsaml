module Saml
  module Elements
    class SPSSODescriptor
      include Saml::ComplexTypes::SSODescriptorType

      class AssertionConsumerService
        include Saml::ComplexTypes::IndexedEndpointType
        tag 'AssertionConsumerService'
      end

      tag 'SPSSODescriptor'

      attribute :authn_requests_signed, Boolean, tag: "AuthnRequestsSigned", default: false
      attribute :want_assertions_signed, Boolean, tag: "WantAssertionsSigned", default: false

      has_many :assertion_consumer_services, AssertionConsumerService
      has_many :attribute_consuming_services, Saml::Elements::AttributeConsumingService

      validates :assertion_consumer_services, presence: true

      def initialize(*args)
        super(*args)
        self.assertion_consumer_services ||= []
      end

      def add_assertion_consumer_service(binding, location, index, default = false)
        assertion_consumer_services << AssertionConsumerService.new(binding:    binding,
                                                                    location:   location,
                                                                    index:      index,
                                                                    is_default: default)
      end

    end
  end
end
