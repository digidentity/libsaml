module Saml
  module Elements
    class AuthnStatement
      include Saml::Base

      tag "AuthnStatement"
      namespace 'saml'

      attribute :authn_instant, Time, tag: "AuthnInstant", on_save: lambda { |val| val.utc.xmlschema }
      attribute :session_index, String, tag: "SessionIndex"

      has_one :subject_locality, Saml::Elements::SubjectLocality, tag: "SubjectLocality"
      has_one :authn_context, Saml::Elements::AuthnContext, tag: "AuthnContext"

      validates :authn_instant, :authn_context, presence: true

      def initialize(*args)
        options = args.extract_options!
        @subject_locality = Saml::Elements::SubjectLocality.new(address: options.delete(:address)) if options[:address]
        @authn_context = Saml::Elements::AuthnContext.new(authn_context_class_ref: options.delete(:authn_context_class_ref)) if options[:authn_context_class_ref]
        super(*(args << options))
      end
    end
  end
end
