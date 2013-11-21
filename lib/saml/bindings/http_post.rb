module Saml
  module Bindings
    class HTTPPost
      class << self
        def create_form_attributes(message, options = {})
          param = message.is_a?(Saml::ComplexTypes::StatusResponseType) ? "SAMLResponse" : "SAMLRequest"

          xml = Saml::Util.sign_xml(message)

          variables        = {}
          variables[param] = Saml::Encoding.encode_64(xml)
          variables["RelayState"] = options[:relay_state] if options[:relay_state]

          {
              location:  message.destination,
              variables: variables
          }
        end

        def receive_message(request, type)
          message             = Saml::Encoding.decode_64(request.params["SAMLRequest"] || request.params["SAMLResponse"])
          request_or_response = Saml.parse_message(message, type)

          verified_request_or_response = Saml::Util.verify_xml(request_or_response, message)
          verified_request_or_response.actual_destination = request.url
          verified_request_or_response
        end
      end
    end
  end
end