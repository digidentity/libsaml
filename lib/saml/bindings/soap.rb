module Saml
  module Bindings
    class SOAP
      class << self

        SOAP_ACTION = 'http://www.oasis-open.org/committees/security'

        def create_response_xml(response)
          Saml::Util.sign_xml(response, :soap)
        end

        def post_message(message, response_type)
          signed_message = Saml::Util.sign_xml(message, :soap)

          http_response = Saml::Util.post(message.destination, signed_message, { 'SOAPAction' => SOAP_ACTION } )

          if http_response.code == "200"
            response = Saml.parse_message(http_response.body, response_type)
            Saml::Util.verify_xml(response, http_response.body)
          else
            nil
          end
        end

        def receive_message(request, type)
          raw_xml = request.body.dup.read
          message = Saml.parse_message(raw_xml, type)

          Saml::Util.verify_xml(message, raw_xml)
        end
      end
    end
  end
end
