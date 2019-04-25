module Saml
  module Elements
    class SubjectConfirmationData
      include Saml::Base

      tag "SubjectConfirmationData"
      register_namespace 'saml', Saml::SAML_NAMESPACE
      namespace 'saml'

      attribute :not_on_or_after, Time, tag: "NotOnOrAfter", on_save: lambda { |val| val.utc.xmlschema }
      attribute :recipient, String, tag: "Recipient"
      attribute :in_response_to, String, tag: "InResponseTo"

      validates :not_on_or_after, :in_response_to, :recipient, presence: true

      def initialize(*args)
        options = args.extract_options!
        super(*(args << options))
        @not_on_or_after = Time.now + Saml::Config.max_issue_instant_offset.minutes
      end
    end
  end
end
