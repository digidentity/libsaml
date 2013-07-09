module Saml
  module ComplexTypes
    module EndpointType
      extend ActiveSupport::Concern
      include Saml::Base

      included do
        namespace 'md'

        attribute :binding, String, :tag => "Binding"
        attribute :location, String, :tag => "Location"

        validates :binding, :location, :presence => true
      end
    end
  end
end
