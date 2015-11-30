module Saml
  class LogoutRequest
    include Saml::ComplexTypes::RequestAbstractType

    tag "LogoutRequest"

    attribute :not_on_or_after, Time, :tag => "NotOnOrAfter", :on_save => lambda { |val| val.utc.xmlschema if val.present? }

    element :name_id, String, :tag => "NameID", :namespace => 'saml'

    validates :name_id, :presence => true
  end
end
