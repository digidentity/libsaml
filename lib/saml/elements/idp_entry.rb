module Saml
  module Elements
    class IdpEntry
      include Saml::Base

      tag 'IDPEntry'
      namespace 'samlp'

      attribute :provider_id, String, tag: 'ProviderID'
      attribute :name, String, tag: 'Name'
      attribute :loc, String, tag: 'Loc'

      validates :provider_id, presence: true
    end
  end
end
