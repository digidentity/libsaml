module Saml
  module Provider
    extend ActiveSupport::Concern

    def assertion_consumer_service_url(index = nil)
      find_indexed_service_url(sp_descriptor.assertion_consumer_services, index)
    end

    # @param [Symbol] type (see #descriptor)
    def artifact_resolution_service_url(index = nil, type = :descriptor)
      find_indexed_service_url(descriptor(type).artifact_resolution_services, index)
    end

    def attribute_consuming_service(index = nil)
      find_indexed_service(sp_descriptor.attribute_consuming_services, index)
    end

    def assertion_consumer_service(index = nil)
      find_indexed_service(sp_descriptor.assertion_consumer_services, index)
    end

    def assertion_consumer_service_indices
      if sp_descriptor.assertion_consumer_services.present?
        sp_descriptor.assertion_consumer_services.map(&:index)
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

    # @param [Symbol] type (see #descriptor)
    def certificate(key_name = nil, use = "signing", type = :descriptor)
      key_descriptor = find_key_descriptor(key_name, use, type)
      key_descriptor.certificate if key_descriptor
    end

    # @param [Symbol] type (see #descriptor)
    def find_key_descriptor(key_name = nil, use = "signing", type = :descriptor)
      descriptor(type).find_key_descriptor(key_name, use)
    end

    def find_key_descriptors_by_use(use, type = :descriptor)
      descriptor(type).find_key_descriptors_by_use(use)
    end

    def find_key_descriptors_by_use_or_without(use, type = :descriptor)
      descriptor(type).find_key_descriptors_by_use_or_without(use)
    end

    def signing_key
      @signing_key || encryption_key
    end

    def encryption_key
      @encryption_key
    end

    def sign(signature_algorithm, data)
      signing_key.sign(digest_method(signature_algorithm).new, data)
    end

    def single_sign_on_service_url(binding)
      find_binding_service(idp_descriptor.single_sign_on_services, binding)
    end

    # @param [Symbol] type (see #descriptor)
    def single_logout_service_url(binding, type = :descriptor)
      find_binding_service(descriptor(type).single_logout_services, binding)
    end

    def attribute_service_url(binding)
      find_binding_service(aa_descriptor.attribute_service, binding)
    end

    def type
      if idp_descriptor(false)
        if sp_descriptor(false)
          "identity_and_service_provider"
        else
          "identity_provider"
        end
      else
        "service_provider"
      end
    end

    def verify(signature_algorithm, signature, data, key_name = nil)
      certificates = if key_name.blank? && iterate_certificates_until_verified?
        find_key_descriptors_by_use_or_without('signing').collect(&:certificate)
      else
        Array(certificate(key_name))
      end
      valid = certificates.any? do |cert|
        cert.public_key.verify(digest_method(signature_algorithm).new, signature, data) rescue false
      end

      # Clear OpenSSL error queue if verification fails - https://bugs.ruby-lang.org/issues/7215
      OpenSSL.errors if !valid

      valid
    end

    def authn_requests_signed?
      sp_descriptor(false).try(:authn_requests_signed)
    end

    def iterate_certificates_until_verified?
      false
    end

    private

    def digest_method(signature_algorithm)
      digest = signature_algorithm && signature_algorithm =~ /sha(.*?)$/i && $1.to_i
      case digest
        when 512 then
          OpenSSL::Digest::SHA512
        when 256 then
          OpenSSL::Digest::SHA256
        else
          OpenSSL::Digest::SHA1
      end
    end

    # @param type [Symbol] Descriptor type, available types :sp_descriptor, :idp_descriptor, :aa_descriptor or :descriptor
    # @return [Saml::ComplexTypes::SSODescriptorType]
    def descriptor(type = :descriptor)
      return sp_descriptor if :sp_descriptor == type
      return idp_descriptor if :idp_descriptor == type
      return aa_descriptor if :aa_descriptor == type
      entity_descriptor.sp_sso_descriptor || entity_descriptor.idp_sso_descriptor || entity_descriptor.attribute_authority_descriptor
    end

    # @return [Saml::Elements::SPSSODescriptor]
    def sp_descriptor(raise_error = true)
      entity_descriptor.sp_sso_descriptor || raise_error &&
          raise(Saml::Errors::InvalidProvider.new("Cannot find service provider with entity_id: #{entity_id}"))
    end

    # @return [Saml::Elements::IDPSSODescriptor]
    def idp_descriptor(raise_error = true)
      entity_descriptor.idp_sso_descriptor || raise_error &&
          raise(Saml::Errors::InvalidProvider.new("Cannot find identity provider with entity_id: #{entity_id}"))
    end

    # Attribute authority descriptor
    # @return [Saml::Elements::AttributeAuthorityDescriptor]
    def aa_descriptor(raise_error = true)
      entity_descriptor.attribute_authority_descriptor || raise_error &&
          raise(Saml::Errors::InvalidProvider.new("Cannot find attribute authority provider with entity_id: #{entity_id}"))
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
