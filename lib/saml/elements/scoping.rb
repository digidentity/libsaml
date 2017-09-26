module Saml
  module Elements
    class Scoping
      include Saml::Base

      tag 'Scoping'
      namespace 'samlp'

      has_one :idp_list, Saml::Elements::IdpList
    end
  end
end
