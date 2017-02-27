require 'xmlmapper'

module Saml
  module ComplexTypes
    module RequestAbstractType
      extend ActiveSupport::Concern
      include Saml::Base
      include Saml::XMLHelpers

      included do
        register_namespace 'samlp', Saml::SAMLP_NAMESPACE
        register_namespace 'saml', Saml::SAML_NAMESPACE
        namespace 'samlp'

        attribute :_id, String, tag: 'ID'
        attribute :version, String, tag: 'Version'
        attribute :issue_instant, Time, tag: 'IssueInstant', on_save: lambda { |val| val.utc.xmlschema if val.present? }
        attribute :consent, String, tag: 'Consent'

        attribute :destination, String, tag: 'Destination'
        element :issuer, String, namespace: 'saml', tag: 'Issuer'

        has_one :signature, Saml::Elements::Signature, xpath: "./"
        has_one :extensions, Saml::Elements::SAMLPExtensions

        attr_accessor :actual_destination

        validates :_id, :version, :issue_instant, presence: true

        validates :version, inclusion: %w(2.0)
        validate :check_destination, if: lambda { |val|
          val.destination.present? && val.actual_destination.present?
        }
        validate :check_issue_instant, if: lambda { |val| val.issue_instant.present? }
      end

      def initialize(*args)
        super(*args)
        @_id           ||= Saml.generate_id
        @issue_instant ||= Time.now
        @issuer        ||= Saml.current_provider.entity_id
        @version       ||= Saml::SAML_VERSION
      end

      # @return [Saml::Provider]
      def provider
        Saml.provider(issuer)
      end

      private

      def check_issue_instant
        errors.add(:issue_instant, :too_old) if issue_instant < Time.now - Saml::Config.max_issue_instant_offset.minutes
        errors.add(:issue_instant, :too_new) if issue_instant > Time.now + Saml::Config.max_issue_instant_offset.minutes
      end

      def check_destination
        errors.add(:destination, :invalid) unless actual_destination.start_with?(destination)
      end
    end
  end
end
