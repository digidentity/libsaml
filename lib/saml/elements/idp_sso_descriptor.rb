module Saml
  module Elements
    class IDPSSODescriptor
      include Saml::ComplexTypes::SSODescriptorType

      class SingleSignOnService
        include Saml::ComplexTypes::EndpointType
        tag 'SingleSignOnService'
      end

      tag 'IDPSSODescriptor'

      has_many :single_sign_on_services, SingleSignOnService

      validates :single_sign_on_services, :presence => true

      def initialize(*args)
        super(*args)
        self.single_sign_on_services ||= []
      end
    end
  end
end
