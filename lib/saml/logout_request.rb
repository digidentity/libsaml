module Saml
  class LogoutRequest
    include Saml::ComplexTypes::RequestAbstractType

    tag "LogoutRequest"
    element :name_id, String, :tag => "NameID", :namespace => 'saml'

    validates :name_id, :presence => true
  end
end
