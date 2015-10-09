module Saml
  module ComplexTypes
    module SSODescriptorType
      extend ActiveSupport::Concern
      include Saml::Base

      include RoleDescriptorType

      class ArtifactResolutionService
        include Saml::ComplexTypes::IndexedEndpointType

        tag 'ArtifactResolutionService'
        namespace 'md'
      end

      class SingleLogoutService
        include Saml::ComplexTypes::EndpointType

        tag 'SingleLogoutService'
        namespace 'md'
      end

      included do
        namespace 'md'

        has_many :artifact_resolution_services, ArtifactResolutionService
        has_many :single_logout_services, SingleLogoutService
        has_many :name_id_formats, Saml::Elements::NameIdFormat
      end

      def initialize(*args)
        super(*args)
        @single_logout_services       ||= []
        @artifact_resolution_services ||= []
      end
    end
  end
end
