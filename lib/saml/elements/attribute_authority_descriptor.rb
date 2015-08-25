module Saml
  module Elements
    class AttributeAuthorityDescriptor
      include Saml::ComplexTypes::RoleDescriptorType

      class AttributeService
        include Saml::ComplexTypes::EndpointType
        tag 'AttributeService'
      end

      tag 'AttributeAuthorityDescriptor'

      has_many :attribute_service, AttributeService
      has_many :name_id_format, Saml::Elements::NameIdFormat

      validates :attribute_service, :presence => true

    end
  end
end
