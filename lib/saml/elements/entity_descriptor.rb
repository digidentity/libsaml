module Saml
  module Elements
    class EntityDescriptor
      include Saml::Base
      include Saml::XMLHelpers

      register_namespace 'md', Saml::MD_NAMESPACE

      tag 'EntityDescriptor'
      namespace 'md'

      attribute :_id, String, :tag => 'ID'
      attribute :name, String, :tag => "Name"
      attribute :entity_id, String, :tag => "entityID"
      attribute :valid_until, Time, :tag => "validUntil"
      attribute :cache_duration, Integer, :tag => "cacheDuration"

      has_one :signature, Saml::Elements::Signature

      has_one :extensions, Saml::Elements::MDExtensions

      has_one :organization, Saml::Elements::Organization
      has_many :contact_persons, Saml::Elements::ContactPerson

      has_one :idp_sso_descriptor, Saml::Elements::IDPSSODescriptor
      has_one :sp_sso_descriptor, Saml::Elements::SPSSODescriptor

      validates :entity_id, :presence => true

      def initialize(*args)
        super(*args)
        @contact_persons ||= []
        @_id             ||= Saml.generate_id
      end

    end
  end
end
