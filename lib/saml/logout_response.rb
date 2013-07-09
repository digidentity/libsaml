module Saml
  class LogoutResponse
    include Saml::ComplexTypes::StatusResponseType

    tag "LogoutResponse"

    def partial_logout?
      !success? && status.status_code.partial_logout?
    end
  end
end
