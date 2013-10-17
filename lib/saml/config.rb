module Saml
  module Config
    mattr_accessor :provider_type
    @@provider_type = "service_provider"

    mattr_accessor :provider_store
    @@provider_store = Saml::ProviderStores::File.new

    mattr_accessor :entity_id
    @@entity_id = 'SamlEntity'

    mattr_accessor :max_issue_instant_offset
    @@max_issue_instant_offset = 2

    mattr_accessor :ssl_private_key_file
    @@ssl_private_key_file = 'SSL_PRIVATE_KEY_FILE'

    mattr_accessor :ssl_certificate
    @@ssl_certificate = 'SSL_CERTIFICATE'

    mattr_accessor :ssl_certificate_file
    @@ssl_certificate_file = 'SSL_CERTIFICATE_FILE'
  end
end
