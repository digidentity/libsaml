module Saml
  module Elements
    class SubjectLocality
      include Saml::Base

      tag "SubjectLocality"
      namespace 'saml'

      attribute :address, String, tag: "Address"
    end
  end
end
