module Saml
  module ComplexTypes
    module RoleDescriptorType
      extend ActiveSupport::Concern
      include Saml::Base

      included do
        namespace 'md'

        PROTOCOL_SUPPORT_ENUMERATION = 'urn:oasis:names:tc:SAML:2.0:protocol' unless defined?(PROTOCOL_SUPPORT_ENUMERATION)

        attribute :_id, String, tag: 'ID'
        attribute :valid_until, Time, tag: 'validUntil'
        attribute :cache_duration, String, tag: 'cacheDuration'
        attribute :protocol_support_enumeration, String, tag: 'protocolSupportEnumeration'
        attribute :error_url, String, tag: 'errorURL'

        has_many :key_descriptors, Saml::Elements::KeyDescriptor

        validates :protocol_support_enumeration, presence: true, inclusion: [PROTOCOL_SUPPORT_ENUMERATION]
      end

      def initialize(*args)
        super(*args)
        @key_descriptors              ||= []
        @protocol_support_enumeration ||= PROTOCOL_SUPPORT_ENUMERATION
      end

      def find_key_descriptor(key_name, use)
        return key_descriptors.first unless key_name_or_use_specified?

        key_descriptors_by_use = find_key_descriptors_by_use_or_without(use)

        if key_name.present? && key_name_specified?
          key_descriptors_by_use.find { |key| key.key_info.key_name == key_name }
        else
          key_descriptors_by_use.first
        end
      end

      def find_key_descriptors_by_use(use)
        key_descriptors.select { |key| key.use == use }
      end

      private

      def find_key_descriptors_by_use_or_without(use)
        key_descriptors.select { |key| key.use == use || key.use.blank? }
      end

      def key_name_or_use_specified?
        key_descriptors.any? { |key| key.use.present? || key.key_info.key_name.present? }
      end

      def key_name_specified?
        key_descriptors.any? { |key| key.key_info.key_name.present? }
      end
    end
  end
end
