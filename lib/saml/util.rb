module Saml
  class Util
    class << self
      def parse_params(url)
        query = URI.parse(url).query
        return {} unless query

        params = {}
        query.split(/[&;]/).each do |pairs|
          key, value = pairs.split('=',2)
          params[key] = value
        end

        params
      end

      def post(location, message)
        request = HTTPI::Request.new

        request.url                     = location
        request.headers['Content-Type'] = 'text/xml'
        request.body                    = message
        request.auth.ssl.cert_file      = Saml::Config.ssl_certificate_file
        request.auth.ssl.cert_key_file  = Saml::Config.ssl_private_key_file

        HTTPI.post request
      end

      def sign_xml(message, format = :xml, &block)
        message.add_signature

        document = Xmldsig::SignedDocument.new(message.send("to_#{format}"))
        if block_given?
          document.sign(&block)
        else
          document.sign do |data, signature_algorithm|
            message.provider.sign(signature_algorithm, data)
          end
        end
      end

      def verify_xml(message, raw_body)
        document = Xmldsig::SignedDocument.new(raw_body)

        signature_valid = document.validate do |signature, data, signature_algorithm|
          message.provider.verify(signature_algorithm, signature, data)
        end

        raise Saml::Errors::SignatureInvalid.new unless signature_valid

        message.class.parse(document.signed_nodes.first.to_xml, single: true)
      end
    end
  end
end
