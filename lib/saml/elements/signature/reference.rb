module Saml
  module Elements
    class Signature
      class Reference
        include Saml::Base

        tag "Reference"
        namespace 'ds'

        attribute :uri, String, :tag => "URI"
        element :transforms, Transforms
        element :digest_method, DigestMethod
        element :digest_value, String, :tag => "DigestValue", :state_when_nil => true

        def initialize(*args)
          options = args.extract_options!
          @transforms    = Transforms.new(:inclusive_namespaces => options.delete(:inclusive_namespaces))
          @digest_method = DigestMethod.new
          super(*args)
        end
      end
    end
  end
end
