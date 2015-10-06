module Saml
  module ComplexTypes
    module SubjectQueryAbstractType
      extend ActiveSupport::Concern

      include RequestAbstractType

      included do
        element :subject, Saml::Elements::Subject

        validates :subject, presence: true
      end

      def initialize(*args)
        options = args.extract_options!
        @subject = Saml::Elements::Subject.new(
          name_id: options.delete(:name_id),
          name_id_format: options.delete(:name_id_format),
          recipient: options.delete(:recipient),
          in_response_to: options.delete(:in_response_to)
        )
        super(*(args << options))
      end
    end
  end
end

