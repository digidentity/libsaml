module Saml
  module Elements
    class PublicationInfo
      include Saml::Base
      include Saml::XMLHelpers

      tag 'PublicationInfo'
      register_namespace 'mdrpi', Saml::MD_RPI_NAMESPACE
      namespace 'mdrpi'

      attribute :publisher, String, tag: 'publisher'
      attribute :creation_instant, Time, tag: 'creationInstant', on_save: lambda { |val| val.utc.xmlschema if val.present? }
      attribute :publication_id, String, tag: 'publicationId'

      validates :publisher, presence: true

    end
  end
end
