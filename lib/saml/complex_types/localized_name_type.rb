module Saml
  module ComplexTypes
    module LocalizedNameType
      extend ActiveSupport::Concern
      include Saml::Base

      included do
        attribute :language, String, tag: 'xml:lang'

        validates :language, presence: true
      end
    end
  end
end
