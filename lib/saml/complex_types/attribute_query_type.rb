module Saml
  module ComplexTypes
    module AttributeQueryType
      extend ActiveSupport::Concern

      include SubjectQueryAbstractType

      included do
        has_many :attributes, Saml::Elements::Attribute
      end

      def initialize(*args)
        options = args.extract_options!
        super(*(args << options))
        @attributes = []
      end
    end
  end
end

