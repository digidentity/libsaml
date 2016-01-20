module Saml
  module ProviderStores
    class File
      attr_accessor :providers

      def initialize(metadata_dir = "config/metadata",
                     encryption_key_file = "config/ssl/key.pem", encryption_key_password = nil,
                     signing_key_file = nil, signing_key_password = nil)
        @mutex         = Mutex.new
        self.providers = {}

        load_files(metadata_dir, encryption_key_file, encryption_key_password, signing_key_file, signing_key_password)
      end

      def find_by_entity_id(entity_id)
        providers[entity_id]
      end

      # Returns provider by source_id or nil if not found.
      def find_by_source_id(source_id)
        providers.find do |entity_id, _|
          Digest::SHA1.digest(entity_id) == source_id
        end.to_a[1]
      end

      def load_files(metadata_dir, encryption_key_file, encryption_key_password = nil,
                     sign_key_file = nil, sign_key_password = nil)
        Dir[::File.join(metadata_dir, '*.xml')].each do |file|
          add_metadata(::File.read(file), get_private_key(encryption_key_file, encryption_key_password),
                       sign_key_file.present? ? get_private_key(sign_key_file, sign_key_password) : nil)
        end
      end

      def add_metadata(metadata_xml, encryption_key = nil, signing_key = nil)
        entity_descriptor = Saml::Elements::EntityDescriptor.parse(metadata_xml, single: true)
        type              = entity_descriptor.sp_sso_descriptor.present? ? 'service_provider' : 'identity_provider'
        provider          = BasicProvider.new(entity_descriptor, encryption_key, type, signing_key)

        @mutex.synchronize do
          providers[provider.entity_id] = provider
        end
      end

      private

      def get_private_key(file, password)
        return OpenSSL::PKey::RSA.new(::File.read(file)) unless password.present?
        OpenSSL::PKey::RSA.new(::File.read(file), password)
      end
    end
  end
end
