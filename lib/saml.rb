require 'active_support/all'
require 'active_model'
require 'saml/base'
require 'saml/xml_helpers'
require 'saml/encoding'
require 'saml/util'
require 'saml/notification'
require 'saml/attribute_fetcher'
require 'xmlenc'
require 'xmldsig'
require "net/https"
require "uri"

module Saml
  MD_NAMESPACE       = 'urn:oasis:names:tc:SAML:2.0:metadata'
  MD_RPI_NAMESPACE   = 'urn:oasis:names:tc:SAML:metadata:rpi'
  MD_ATTR_NAMESPACE  = 'urn:oasis:names:tc:SAML:metadata:attribute'
  SAML_NAMESPACE     = 'urn:oasis:names:tc:SAML:2.0:assertion'
  SAMLP_NAMESPACE    = 'urn:oasis:names:tc:SAML:2.0:protocol'
  XS_NAMESPACE       = 'http://www.w3.org/2001/XMLSchema'
  XSI_NAMESPACE      = 'http://www.w3.org/2001/XMLSchema-instance'
  XML_DSIG_NAMESPACE = 'http://www.w3.org/2000/09/xmldsig#'
  SAML_VERSION       = '2.0'

  module Errors
    class SamlError < StandardError
    end
    class SignatureInvalid < SamlError
    end
    class SignatureMissing < SamlError
    end
    class InvalidProvider < SamlError
    end
    class UnparseableMessage < SamlError
    end
    class MetadataDownloadFailed < SamlError
    end
    class InvalidStore < SamlError
      def initialize(store = '')
        @store = store
      end

      def message
        if @store.nil? || @store == ''
          'Store cannot be blank'
        else
          "Store #{@store} not registered"
        end
      end
    end
  end

  module TopLevelCodes
    SUCCESS          = 'urn:oasis:names:tc:SAML:2.0:status:Success'
    REQUESTER        = 'urn:oasis:names:tc:SAML:2.0:status:Requester'
    RESPONDER        = 'urn:oasis:names:tc:SAML:2.0:status:Responder'
    VERSION_MISMATCH = 'urn:oasis:names:tc:SAML:2.0:status:VersionMismatch'

    ALL = [SUCCESS, REQUESTER, RESPONDER, VERSION_MISMATCH]
  end

  module SubStatusCodes
    AUTHN_FAILED        = 'urn:oasis:names:tc:SAML:2.0:status:AuthnFailed'
    NO_AUTHN_CONTEXT    = 'urn:oasis:names:tc:SAML:2.0:status:NoAuthnContext'
    PARTIAL_LOGOUT      = 'urn:oasis:names:tc:SAML:2.0:status:PartialLogout'
    REQUEST_DENIED      = 'urn:oasis:names:tc:SAML:2.0:status:RequestDenied'
    REQUEST_UNSUPPORTED = 'urn:oasis:names:tc:SAML:2.0:status:RequestUnsupported'
    UNKNOWN_PRINCIPAL   = 'urn:oasis:names:tc:SAML:2.0:status:UnknownPrincipal'

    ALL = [AUTHN_FAILED, NO_AUTHN_CONTEXT, PARTIAL_LOGOUT, REQUEST_DENIED, REQUEST_UNSUPPORTED, UNKNOWN_PRINCIPAL]
  end

  module Bindings
    require 'saml/bindings/http_artifact'
    require 'saml/bindings/http_redirect'
    require 'saml/bindings/http_post'
    require 'saml/bindings/soap'
  end

  module ClassRefs
    UNSPECIFIED                    = 'urn:oasis:names:tc:SAML:2.0:ac:classes:unspecified'
    PASSWORD_PROTECTED             = 'urn:oasis:names:tc:SAML:2.0:ac:classes:PasswordProtectedTransport'
    MOBILE_TWO_FACTOR_UNREGISTERED = 'urn:oasis:names:tc:SAML:2.0:ac:classes:MobileTwoFactorUnregistered'
    MOBILE_TWO_FACTOR_CONTRACT     = 'urn:oasis:names:tc:SAML:2.0:ac:classes:MobileTwoFactorContract'
    MOBILE_SMARTCARD_PKI           = 'urn:oasis:names:tc:SAML:2.0:ac:classes:SmartcardPKI'

    ALL_CLASS_REFS     = [UNSPECIFIED,
                          PASSWORD_PROTECTED,
                          MOBILE_TWO_FACTOR_UNREGISTERED,
                          MOBILE_TWO_FACTOR_CONTRACT,
                          MOBILE_SMARTCARD_PKI]
    ORDERED_CLASS_REFS = ALL_CLASS_REFS
  end

  module ComplexTypes
    require 'saml/complex_types/role_descriptor_type'
    require 'saml/complex_types/request_abstract_type'
    require 'saml/complex_types/status_response_type'
    require 'saml/complex_types/endpoint_type'
    require 'saml/complex_types/indexed_endpoint_type'
    require 'saml/complex_types/sso_descriptor_type'
    require 'saml/complex_types/attribute_type'
    require 'saml/complex_types/localized_name_type'
    require 'saml/complex_types/statement_abstract_type'
    require 'saml/complex_types/subject_query_abstract_type'
    require 'saml/complex_types/attribute_query_type'
    require 'saml/complex_types/evidence_type'
    require 'saml/complex_types/advice_type'
  end

  module Elements
    require 'saml/elements/signature'
    require 'saml/elements/authenticating_authority'
    require 'saml/elements/subject_locality'
    require 'saml/elements/authn_context'
    require 'saml/elements/audience'
    require 'saml/elements/audience_restriction'
    require 'saml/elements/sub_status_code'
    require 'saml/elements/status_code'
    require 'saml/elements/status_detail'
    require 'saml/elements/status'
    require 'saml/elements/subject_confirmation_data'
    require 'saml/elements/subject_confirmation'
    require 'saml/elements/encrypted_assertion'
    require 'saml/elements/encrypted_attribute'
    require 'saml/elements/name_id'
    require 'saml/elements/name_id_format'
    require 'saml/elements/encrypted_id'
    require 'saml/elements/attribute_value'
    require 'saml/elements/attribute'
    require 'saml/elements/attribute_statement'
    require 'saml/elements/entity_attributes'
    require 'saml/elements/publication_info'
    require 'saml/elements/md_extensions'
    require 'saml/elements/samlp_extensions'
    require 'saml/elements/service_name'
    require 'saml/elements/service_description'
    require 'saml/elements/requested_attribute'
    require 'saml/elements/attribute_consuming_service'
    require 'saml/elements/subject'
    require 'saml/elements/conditions'
    require 'saml/elements/authn_statement'
    require 'saml/elements/requested_authn_context'
    require 'saml/elements/key_descriptor'
    require 'saml/elements/organization_name'
    require 'saml/elements/organization_display_name'
    require 'saml/elements/organization_url'
    require 'saml/elements/organization'
    require 'saml/elements/contact_person'
    require 'saml/elements/advice'
    require 'saml/elements/idp_sso_descriptor'
    require 'saml/elements/sp_sso_descriptor'
    require 'saml/elements/attribute_authority_descriptor'
    require 'saml/elements/entity_descriptor'
    require 'saml/elements/entities_descriptor'
    require 'saml/elements/attribute_query'
    require 'saml/elements/evidence'
  end

  module Rails
    require 'saml/rails/controller_helper'
  end

  require 'saml/assertion'
  require 'saml/authn_request'
  require 'saml/artifact'
  require 'saml/response'
  require 'saml/artifact_resolve'
  require 'saml/artifact_response'
  require 'saml/logout_request'
  require 'saml/logout_response'
  require 'saml/provider'
  require 'saml/basic_provider'
  require 'saml/null_provider'

  module ProviderStores
    require 'saml/provider_stores/file'
    require 'saml/provider_stores/url'
  end

  module ProtocolBinding
    HTTP_ARTIFACT = 'urn:oasis:names:tc:SAML:2.0:bindings:HTTP-Artifact'
    HTTP_POST     = 'urn:oasis:names:tc:SAML:2.0:bindings:HTTP-POST'
    HTTP_REDIRECT = 'urn:oasis:names:tc:SAML:2.0:bindings:HTTP-Redirect'
    SOAP          = 'urn:oasis:names:tc:SAML:2.0:bindings:SOAP'
  end

  def self.current_provider
    Thread.current['saml_current_provider'] || NullProvider.new
  end

  def self.current_provider=(provider)
    Thread.current['saml_current_provider'] = provider
  end

  def self.current_store
    store_name = Thread.current['saml_current_store']
    Saml::Config.registered_stores[store_name] ||
        Saml::Config.registered_stores[Saml::Config.default_store] ||
        raise(Errors::InvalidStore.new(store_name))
  end

  def self.current_store=(store_name)
    Thread.current['saml_current_store'] = store_name
  end

  def self.setup
    yield Saml::Config
  end

  def self.generate_id
    "_#{::SecureRandom.hex(20)}"
  end

  def self.provider(entity_id)
    if current_provider.entity_id == entity_id
      current_provider
    else
      current_store.find_by_entity_id(entity_id) || raise(Saml::Errors::InvalidProvider.new("Cannot find provider with entity_id: #{entity_id}"))
    end
  end

  def self.parse_message(message, type)
    if %w(authn_request response logout_request logout_response artifact_resolve artifact_response).include?(type.to_s)
      klass = "Saml::#{type.to_s.camelize}".constantize
      klass.parse(message, single: true)
    elsif klass = type.to_s.camelize.safe_constantize
      klass.parse(message, single: true)
    else
      nil
    end
  end
end

require 'saml/config'
