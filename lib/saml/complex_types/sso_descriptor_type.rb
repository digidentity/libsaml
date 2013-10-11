module Saml
  module ComplexTypes
    module SSODescriptorType
      extend ActiveSupport::Concern
      include Saml::Base

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

        PROTOCOL_SUPPORT_ENUMERATION = "urn:oasis:names:tc:SAML:2.0:protocol" unless defined?(PROTOCOL_SUPPORT_ENUMERATION)

        attribute :protocol_support_enumeration, String, :tag => "protocolSupportEnumeration"
        attribute :valid_until, Time, :tag => "validUntil"
        attribute :cache_duration, Integer, :tag => "cacheDuration"
        attribute :error_url, String, :tag => "errorURL"

        has_many :key_descriptors, Saml::Elements::KeyDescriptor

        has_many :artifact_resolution_services, ArtifactResolutionService
        has_many :single_logout_services, SingleLogoutService

        validates :protocol_support_enumeration, :presence => true, :inclusion => [PROTOCOL_SUPPORT_ENUMERATION]
      end

      def initialize(*args)
        super(*args)
        @single_logout_services       ||= []
        @key_descriptors              ||= []
        @artifact_resolution_services ||= []
        @protocol_support_enumeration ||= PROTOCOL_SUPPORT_ENUMERATION
      end

      def find_key_descriptor(key_name, use)
        key_descriptors_by_use = find_key_descriptors_by_use(use)

        if key_name.present?
          key_descriptors_by_use.find { |key| key.key_info.key_name == key_name }
        else
          key_descriptors_by_use.first
        end
      end

      private

      def find_key_descriptors_by_use(use)
        key_descriptors.select { |key| key.use == use || key.use == "" }
      end
    end
  end
end
