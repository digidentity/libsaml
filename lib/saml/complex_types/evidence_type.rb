module Saml
  module ComplexTypes
    module EvidenceType
      extend ActiveSupport::Concern

      included do
        require 'saml/assertion'

        has_many :assertion, ::Saml::Assertion

        validates :assertion, presence: true
      end

      def initialize(*args)
        options = args.extract_options!
        @assertion = options.delete(:assertion)
        super(*(args << options))
      end
    end
  end
end


