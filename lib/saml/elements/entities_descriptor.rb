module Saml
  module Elements
    class EntitiesDescriptor
      include Saml::Base
      include Saml::XMLHelpers

      register_namespace "md", Saml::MD_NAMESPACE

      tag "EntitiesDescriptor"
      namespace "md"

      attribute :_id, String, tag: "ID"
      attribute :name, String, tag: "Name"
      attribute :valid_until, Time, tag: "validUntil"
      attribute :cache_duration, String, tag: "cacheDuration"

      has_one :signature, Saml::Elements::Signature

      has_many :entities_descriptors, Saml::Elements::EntitiesDescriptor
      has_many :entity_descriptors, Saml::Elements::EntityDescriptor

      validates :entities_descriptors, length: { minimum: 1 }, if: lambda { |ed| ed.entity_descriptors.blank? }
      validates :entity_descriptors, length: { minimum: 1 }, if: lambda { |ed| ed.entities_descriptors.blank? }

    end
  end
end
