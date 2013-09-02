require 'happymapper'

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

        attribute :_id, String, :tag => 'ID'
        attribute :version, String, :tag => "Version"
        attribute :issue_instant, Time, :tag => "IssueInstant", :on_save => lambda { |val| val.utc.xmlschema }
        attribute :consent, String, :tag => "Consent"

        attribute :destination, String, :tag => "Destination"
        element :issuer, String, :namespace => 'saml', :tag => "Issuer"

        has_one :signature, Saml::Elements::Signature
        has_one :extensions, Saml::Elements::SAMLPExtensions

        validates :_id, :version, :issue_instant, :presence => true

        validates :version, inclusion: %w(2.0)
        validate :check_issue_instant, :if => "issue_instant.present?"
      end

      def initialize(*args)
        super(*args)
        @_id           ||= Saml.generate_id
        @issue_instant ||= Time.now
        @issuer        ||= Saml::Config.entity_id
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
    end
  end
end
