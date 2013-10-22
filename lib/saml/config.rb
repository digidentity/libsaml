module Saml
  module Config
    mattr_accessor :provider_type
    @@provider_type = "service_provider"

    mattr_accessor :max_issue_instant_offset
    @@max_issue_instant_offset = 2

    mattr_accessor :ssl_private_key_file
    @@ssl_private_key_file = 'SSL_PRIVATE_KEY_FILE'

    mattr_accessor :ssl_certificate
    @@ssl_certificate = 'SSL_CERTIFICATE'

    mattr_accessor :ssl_certificate_file
    @@ssl_certificate_file = 'SSL_CERTIFICATE_FILE'

    mattr_accessor :registered_stores
    @@registered_stores = {}

    mattr_accessor :default_store

    def register_store(name, store, options = {})
      registered_stores[name] = store
      self.default_store = name if options[:default]
    end

    module_function :register_store

  end
end
