module Saml
  module Elements
    class AttributeConsumingService
      include Saml::Base

      tag "AttributeConsumingService"

      attribute :index, Integer, :tag => "index"
      attribute :is_default, HappyMapper::Boolean, :tag => "isDefault"

      has_many :service_names, ServiceName
      has_many :service_descriptions, ServiceDescription
      has_many :requested_attributes, RequestedAttribute

      validates :index, :service_names, :requested_attributes, :presence => true
    end
  end
end
