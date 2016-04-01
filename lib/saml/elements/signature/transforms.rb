module Saml
  module Elements
    class Signature
      class Transforms
        include Saml::Base

        tag "Transforms"
        namespace 'ds'

        has_many :transform, Transform, :tag => "Transform"

        def initialize(*args)
          options = args.extract_options!
          @transform = [Transform.new(:algorithm => "http://www.w3.org/2000/09/xmldsig#enveloped-signature"),
                        Transform.new(:algorithm            => "http://www.w3.org/2001/10/xml-exc-c14n#",
                                      :inclusive_namespaces => InclusiveNamespaces.new(:prefix_list => options[:inclusive_namespaces]))]
          super(*args)
        end
      end
    end
  end
end
