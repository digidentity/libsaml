module Saml
  module Config
    mattr_accessor :provider_type
    @@provider_type = "service_provider"

    mattr_accessor :provider_store
    @@provider_store = Saml::ProviderStores::File.new

    mattr_accessor :entity_id
    @@entity_id = 'SamlEntity'

    mattr_accessor :authn_context_levels
    @@authn_context_levels = {}

    mattr_accessor :artifact_ttl
    @@artifact_ttl = 15

    mattr_accessor :private_key
    @@private_key = 'PRIVATE_KEY'

    mattr_accessor :private_key_file
    @@private_key_file = 'PRIVATE_KEY_FILE'

    mattr_accessor :max_issue_instant_offset
    @@max_issue_instant_offset = 2

    mattr_accessor :absolute_timeout
    @@absolute_timeout = 8*60

    mattr_accessor :graceperiod_timeout
    @@graceperiod_timeout = 15

    mattr_accessor :session_timeout
    @@session_timeout = 15

    # SSL
    mattr_accessor :ssl_private_key
    @@ssl_private_key = 'SSL_PRIVATE_KEY'

    mattr_accessor :ssl_private_key_file
    @@ssl_private_key_file = 'SSL_PRIVATE_KEY_FILE'

    mattr_accessor :ssl_certificate
    @@ssl_certificate = 'SSL_CERTIFICATE'

    mattr_accessor :ssl_certificate_file
    @@ssl_certificate_file = 'SSL_CERTIFICATE_FILE'
  end
end
