module Saml
  module ProviderStores
    class Url
      attr_accessor :providers
      class << self
        def find_by_metadata_location(entity_id)
          metadata          = Saml::Util.download_metadata_xml(entity_id)
          entity_descriptor = Saml::Elements::EntityDescriptor.parse(metadata, single: true)
          type              = entity_descriptor.sp_sso_descriptor.present? ? "service_provider" : "identity_provider"

          BasicProvider.new(entity_descriptor, nil, type, nil)
        end

        alias_method :find_by_entity_id, :find_by_metadata_location
      end
    end
  end
end
