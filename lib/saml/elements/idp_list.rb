module Saml
  module Elements
    class IdpList
      include Saml::Base

      tag 'IDPList'
      namespace 'samlp'

      has_many :idp_entries, Saml::Elements::IdpEntry

      validates :idp_entries, presence: true

      def initialize(*args)
        super(*args)
        self.idp_entries ||= []
      end
    end
  end
end
