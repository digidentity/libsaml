module Saml
  module Elements
    class Signature
      class InclusiveNamespaces
        include Saml::Base

        register_namespace 'ec', "http://www.w3.org/2001/10/xml-exc-c14n#"
        namespace 'ec'
        tag 'InclusiveNamespaces'

        attribute :prefix_list, String, :tag => "PrefixList"

        def initialize(*args)
          @prefix_list = Saml::Config.inclusive_namespaces_prefix_list
          super(*args)
        end
      end
    end
  end
end
