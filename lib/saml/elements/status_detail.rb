module Saml
  module Elements
    class StatusDetail
      include Saml::Base

      tag "StatusDetail"
      namespace 'samlp'

      element :status_value, String, :tag => 'StatusValue'

      def initialize(*args)
        options          = args.extract_options!
        @status_value = options.delete(:status_value) if options[:status_value]
        super(*(args << options))
      end
    end
  end
end
