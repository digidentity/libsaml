module Saml
  module Provider
    extend ActiveSupport::Concern

    def assertion_consumer_service_url(index = nil)
      find_indexed_service_url(descriptor.assertion_consumer_services, index)
    end

    def artifact_resolution_service_url(index = nil)
      find_indexed_service_url(descriptor.artifact_resolution_services, index)
    end

    def attribute_consuming_service(index = nil)
      find_indexed_service(descriptor.attribute_consuming_services, index)
    end

    def assertion_consumer_service(index = nil)
      find_indexed_service(descriptor.assertion_consumer_services, index)
    end

    def assertion_consumer_service_indices
      if descriptor.assertion_consumer_services.present?
        descriptor.assertion_consumer_services.map(&:index)
      else
        []
      end
    end

    def entity_descriptor
      @entity_descriptor
    end

    def entity_id
      entity_descriptor.entity_id
    end

    def certificate(key_name = nil, use = "signing")
      key_descriptor = find_key_descriptor(key_name, use)
      key_descriptor.certificate if key_descriptor
    end

    def find_key_descriptor(key_name = nil, use = "signing")
      descriptor.find_key_descriptor(key_name, use)
    end

    def private_key
      @private_key
    end

    def sign(signature_algorithm, data)
      private_key.sign(digest_method(signature_algorithm).new, data)
    end

    def single_sign_on_service_url(binding)
      find_binding_service(descriptor.single_sign_on_services, binding)
    end

    def single_logout_service_url(binding)
      find_binding_service(descriptor.single_logout_services, binding)
    end

    def attribute_service_url(binding)
      find_binding_service(entity_descriptor.attribute_authority_descriptor.attribute_service, binding)
    end

    def type
      descriptor.is_a?(Saml::Elements::SPSSODescriptor) ? "service_provider" : "identity_provider"
    end

    def verify(signature_algorithm, signature, data, key_name = nil)
      certificate(key_name).public_key.verify(digest_method(signature_algorithm).new, signature, data) rescue nil
    end

    def authn_requests_signed?
      descriptor.authn_requests_signed
    end

    private

    def digest_method(signature_algorithm)
      digest = signature_algorithm && signature_algorithm =~ /sha(.*?)$/i && $1.to_i
      case digest
        when 256 then
          OpenSSL::Digest::SHA256
        else
          OpenSSL::Digest::SHA1
      end
    end

    # @return [Saml::ComplexTypes::RoleDescriptorType]
    def descriptor
      entity_descriptor.sp_sso_descriptor || entity_descriptor.idp_sso_descriptor || entity_descriptor.attribute_authority_descriptor
    end

    def find_indexed_service_url(service_list, index)
      service = find_indexed_service(service_list, index)
      service.location if service
    end

    def find_indexed_service(service_list, index)
      if index
        service_list.find { |service| service.index == index }
      else
        service_list.find { |service| service.is_default }
      end
    end

    def find_binding_service(service_list, binding)
      service = service_list.find { |service| service.binding == binding }
      service.location if service
    end
  end
end
