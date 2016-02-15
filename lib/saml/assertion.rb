module Saml
  class Assertion
    include Saml::Base
    include Saml::XMLHelpers

    attr_accessor :xml_value

    register_namespace 'samlp', Saml::SAMLP_NAMESPACE
    register_namespace 'saml', Saml::SAML_NAMESPACE

    tag 'Assertion'
    namespace 'saml'

    attribute :_id, String, :tag => 'ID'
    attribute :version, String, :tag => 'Version'
    attribute :issue_instant, Time, :tag => 'IssueInstant', :on_save => lambda { |val| val.utc.xmlschema }

    element :issuer, String, :namespace => 'saml', :tag => 'Issuer'

    has_one   :signature, Saml::Elements::Signature, xpath: './'
    has_one   :subject, Saml::Elements::Subject, xpath: './'
    has_one   :conditions, Saml::Elements::Conditions, xpath: './'
    has_one   :advice, Saml::Elements::Advice, xpath: './'
    has_many  :statements, Saml::ComplexTypes::StatementAbstractType, xpath: './'
    has_many  :authn_statement, Saml::Elements::AuthnStatement, xpath: './'
    has_many  :attribute_statements, Saml::Elements::AttributeStatement, xpath: './'

    validates :_id, :version, :issue_instant, :issuer, :presence => true

    validates :version, inclusion: %w(2.0)
    validate :check_issue_instant, :if => 'issue_instant.present?'

    def initialize(*args)
      options          = args.extract_options!
      if options[:subject].present?
        @subject = options.delete(:subject)
      else
        @subject         = Saml::Elements::Subject.new(:name_id        => options.delete(:name_id),
                                                       :name_id_format => options.delete(:name_id_format),
                                                       :recipient      => options.delete(:recipient),
                                                       :in_response_to => options.delete(:in_response_to))
      end

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
      self.attribute_statement.attributes ||= []
      self.attribute_statement.attributes << Saml::Elements::Attribute.new(name: key, attribute_value: value)
    end

    def fetch_attribute(key)
      Array(fetch_attributes(key)).first
    end

    def fetch_attributes(key)
      return unless self.attribute_statements
      return unless self.attribute_statements.flat_map(&:attributes)
      attribute_statements.flat_map { |attribute_statement| attribute_statement.fetch_attributes(key) }
    end

    def fetch_attribute_value(key)
      Array(fetch_attribute_values(key)).first
    end

    def fetch_attribute_values(key)
      return unless self.attribute_statements
      return unless self.attribute_statements.flat_map(&:attributes)
      attribute_statements.flat_map { |attribute_statement| attribute_statement.fetch_attribute_values(key) }
    end

    def attribute_statement
      attribute_statements.try(:first)
    end

    def attribute_statement=(attribute_statement)
      self.attribute_statements = [attribute_statement]
    end

    private

    def check_issue_instant
      errors.add(:issue_instant, :too_old) if issue_instant < Time.now - Saml::Config.max_issue_instant_offset.minutes
      errors.add(:issue_instant, :too_new) if issue_instant > Time.now + Saml::Config.max_issue_instant_offset.minutes
    end

  end
end
