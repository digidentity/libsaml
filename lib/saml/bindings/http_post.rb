module Saml
  module Bindings
    class HTTPPost
      include Saml::Notification

      class << self
        def create_form_attributes(message, options = {})
          param = message.is_a?(Saml::ComplexTypes::StatusResponseType) ? "SAMLResponse" : "SAMLRequest"

          xml = notify('create_message', Saml::Util.sign_xml(message))

          variables        = {}
          variables[param] = Saml::Encoding.encode_64(xml)
          variables["RelayState"] = options[:relay_state] if options[:relay_state]

          {
              location:  message.destination,
              variables: variables
          }
        end

        def receive_message(request, type)
          receive_xml = request.params["SAMLRequest"] || request.params["SAMLResponse"]
          if receive_xml.nil?
            raise Saml::Errors::InvalidParams, 'require params `SAMLRequest` or `SAMLResponse`'
          end

          message             = Saml::Encoding.decode_64(receive_xml)
          notify('receive_message', message)
          request_or_response = Saml.parse_message(message, type)

          skip_signature_verification = (
            request_or_response.is_a?(Saml::AuthnRequest) &&
            !request_or_response.provider.authn_requests_signed?
          )

          verified_request_or_response = if skip_signature_verification
            request_or_response
          else
            Saml::Util.verify_xml(request_or_response, message)
          end
          verified_request_or_response.actual_destination = request.url
          verified_request_or_response
        end
      end
    end
  end
end
