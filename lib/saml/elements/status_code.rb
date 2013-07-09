module Saml
  module Elements
    class StatusCode
      include Saml::Base

      tag "StatusCode"
      namespace 'samlp'

      attribute :value, String, :tag => "Value"

      has_one :sub_status_code, Saml::Elements::SubStatusCode

      validates :value, :presence => true, :inclusion => TopLevelCodes::ALL

      def initialize(*args)
        options          = args.extract_options!
        @sub_status_code = Saml::Elements::SubStatusCode.new(:value => options.delete(:sub_status_value)) if options[:sub_status_value]
        super(*(args << options))
      end

      def success?
        value == TopLevelCodes::SUCCESS
      end

      def authn_failed?
        sub_status_code.value == SubStatusCodes::AUTHN_FAILED
      end

      def request_denied?
        sub_status_code.value == SubStatusCodes::REQUEST_DENIED
      end

      def no_authn_context?
        sub_status_code.value == SubStatusCodes::NO_AUTHN_CONTEXT
      end

      def partial_logout?
        sub_status_code.value == SubStatusCodes::PARTIAL_LOGOUT
      end
    end
  end
end
