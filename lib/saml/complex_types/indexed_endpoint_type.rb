module Saml
  module ComplexTypes
    module IndexedEndpointType
      extend ActiveSupport::Concern
      include EndpointType

      included do
        attribute :index, Integer, tag: "index"
        attribute :is_default, XmlMapper::Boolean, tag: "isDefault"

        validates :index, presence: true
      end
    end
  end
end
