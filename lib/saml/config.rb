module Saml
  module Config
    mattr_accessor :provider_type
    @@provider_type = "service_provider"

    mattr_accessor :max_issue_instant_offset
    @@max_issue_instant_offset = 2

    mattr_accessor :ssl_private_key
    @@ssl_private_key = nil

    mattr_accessor :ssl_certificate
    @@ssl_certificate = nil

    mattr_accessor :http_ca_file
    @@http_ca_file = nil

    mattr_accessor :registered_stores
    @@registered_stores = {}

    mattr_accessor :default_store

    mattr_accessor :inclusive_namespaces_prefix_list
    @@inclusive_namespaces_prefix_list = "ds saml samlp xs"

    def register_store(name, store, options = {})
      registered_stores[name] = store
      self.default_store = name if options[:default]
    end
    module_function :register_store

    def ssl_private_key_file=(private_key_file)
      if private_key_file.present?
        self.ssl_private_key = OpenSSL::PKey::RSA.new File.read(private_key_file)
      else
        self.ssl_private_key = nil
      end
    end
    module_function :ssl_private_key_file=

    def ssl_certificate_file=(certificate_file)
      if certificate_file.present?
        self.ssl_certificate = OpenSSL::X509::Certificate.new File.read(certificate_file)
      else
        self.ssl_certificate = nil
      end
    end
    module_function :ssl_certificate_file=

  end
end
