module Saml
  module ProviderStores
    class File
      attr_accessor :providers

      def initialize(metadata_dir = "config/metadata", key_file = "config/ssl/key.pem")
        self.providers = []
        Dir[::File.join(metadata_dir, "*.xml")].each do |file|
          entity_descriptor = Saml::Elements::EntityDescriptor.parse(::File.read(file), single: true)
          private_key       = OpenSSL::PKey::RSA.new(::File.read(key_file))
          type              = entity_descriptor.sp_sso_descriptor.present? ? "service_provider" : "identity_provider"

          self.providers << BasicProvider.new(entity_descriptor, private_key, type)
        end
      end

      def find_by_entity_id(entity_id)
        self.providers.find { |provider| provider.entity_id == entity_id }
      end
    end
  end
end
