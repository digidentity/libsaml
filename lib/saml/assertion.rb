module Saml
  class Assertion
    include Saml::Base
    include Saml::XMLHelpers

    register_namespace 'samlp', Saml::SAMLP_NAMESPACE
    register_namespace 'saml', Saml::SAML_NAMESPACE

    tag "Assertion"
    namespace 'saml'

    attribute :_id, String, :tag => 'ID'
    attribute :version, String, :tag => "Version"
    attribute :issue_instant, Time, :tag => "IssueInstant", :on_save => lambda { |val| val.utc.xmlschema }

    element :issuer, String, :namespace => 'saml', :tag => "Issuer"

    has_one   :signature, Saml::Elements::Signature
    has_one   :subject, Saml::Elements::Subject
    has_one   :conditions, Saml::Elements::Conditions
    has_many  :statements, Saml::ComplexTypes::StatementAbstractType
    has_many  :authn_statement, Saml::Elements::AuthnStatement
    has_one   :attribute_statement, Saml::Elements::AttributeStatement

    validates :_id, :version, :issue_instant, :issuer, :presence => true

    validates :version, inclusion: %w(2.0)
    validate :check_issue_instant, :if => "issue_instant.present?"

    def initialize(*args)
      options          = args.extract_options!
      @subject         = Saml::Elements::Subject.new(:name_id        => options.delete(:name_id),
                                                     :name_id_format => options.delete(:name_id_format),
                                                     :recipient      => options.delete(:recipient),
                                                     :in_response_to => options.delete(:in_response_to))
      @conditions      = Saml::Elements::Conditions.new(:audience => options.delete(:audience))
      @authn_statement = Saml::Elements::AuthnStatement.new(:authn_instant           => Time.now,
                                                            :address                 => options.delete(:address),
                                                            :authn_context_class_ref => options.delete(:authn_context_class_ref),
                                                            :session_index           => options.delete(:session_index))
      super(*(args << options))
      @_id           ||= Saml.generate_id
      @issue_instant ||= Time.now
      @issuer        ||= Saml.current_provider.entity_id
      @version       ||= Saml::SAML_VERSION
    end

    # @return [Saml::Provider]
    def provider
      @provider ||= Saml.provider(issuer)
    end

    def add_attribute(key, value)
      self.attribute_statement ||= Saml::Elements::AttributeStatement.new
      self.attribute_statement.attribute ||= []
      self.attribute_statement.attribute << Saml::Elements::Attribute.new(name: key, attribute_value: value)
    end

    def fetch_attribute(key)
      return unless self.attribute_statement
      return unless self.attribute_statement.attribute
      attribute_statement.fetch_attribute(key)
    end

    def fetch_attributes(key)
      return unless self.attribute_statement
      return unless self.attribute_statement.attribute
      attribute_statement.fetch_attributes(key)
    end

    private

    def check_issue_instant
      errors.add(:issue_instant, :too_old) if issue_instant < Time.now - Saml::Config.max_issue_instant_offset.minutes
      errors.add(:issue_instant, :too_new) if issue_instant > Time.now + Saml::Config.max_issue_instant_offset.minutes
    end

  end
end
