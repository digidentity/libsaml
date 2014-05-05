module Saml
  module ProviderStores
    class File
      attr_accessor :providers

      def initialize(metadata_dir = "config/metadata", key_file = "config/ssl/key.pem")
        @mutex         = Mutex.new
        self.providers = {}

        load_files(metadata_dir, key_file)
      end

      def find_by_entity_id(entity_id)
        self.providers[entity_id]
      end

      def load_files(metadata_dir, key_file)
        Dir[::File.join(metadata_dir, "*.xml")].each do |file|
          add_metadata(::File.read(file), OpenSSL::PKey::RSA.new(::File.read(key_file)))
        end
      end

      def add_metadata(metadata_xml, private_key = nil)
        entity_descriptor = Saml::Elements::EntityDescriptor.parse(metadata_xml, single: true)
        type              = entity_descriptor.sp_sso_descriptor.present? ? "service_provider" : "identity_provider"
        provider          = BasicProvider.new(entity_descriptor, private_key, type)

        @mutex.synchronize do
          self.providers[provider.entity_id] = provider
        end
      end
    end
  end
end
