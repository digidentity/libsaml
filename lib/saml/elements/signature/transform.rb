module Saml
  module Elements
    class Signature
      class Transform
        include Saml::Base

        tag "Transform"
        namespace 'ds'

        attribute :algorithm, String, :tag => "Algorithm"
        has_one :inclusive_namespaces, InclusiveNamespaces

        def inclusive_namespaces
          @inclusive_namespaces == [] ? nil : @inclusive_namespaces
        end
      end
    end
  end
end
