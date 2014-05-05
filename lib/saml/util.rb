module Saml
  class Util
    class << self
      def parse_params(url)
        query = URI.parse(url).query
        return {} unless query

        params = {}
        query.split(/[&;]/).each do |pairs|
          key, value  = pairs.split('=', 2)
          params[key] = value
        end

        params
      end

      def post(location, message, additional_headers = {})
        uri = URI.parse(location)

        http             = Net::HTTP.new(uri.host, uri.port)
        http.use_ssl     = uri.scheme == 'https'
        http.verify_mode = OpenSSL::SSL::VERIFY_PEER

        if Saml::Config.ssl_certificate_file.present? && Saml::Config.ssl_private_key_file.present?
          cert = File.read(Saml::Config.ssl_certificate_file)
          key  = File.read(Saml::Config.ssl_private_key_file)

          http.cert = OpenSSL::X509::Certificate.new(cert)
          http.key  = OpenSSL::PKey::RSA.new(key)
        end

        headers = { 'Content-Type' => 'text/xml' }
        headers.merge! additional_headers

        request      = Net::HTTP::Post.new(uri.request_uri, headers)
        request.body = message

        http.request(request)
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

      def encrypt_assertion(assertion, certificate)
        assertion = assertion.to_xml(nil, nil, false) if assertion.is_a?(Assertion) # create xml without instruct

        encrypted_data = Xmlenc::Builder::EncryptedData.new
        encrypted_data.set_encryption_method(algorithm: 'http://www.w3.org/2001/04/xmlenc#aes128-cbc')

        encrypted_key = encrypted_data.encrypt(assertion.to_s)
        encrypted_key.set_encryption_method(algorithm:               'http://www.w3.org/2001/04/xmlenc#rsa-oaep-mgf1p',
                                            digest_method_algorithm: 'http://www.w3.org/2000/09/xmldsig#sha1')
        encrypted_key.encrypt(certificate.public_key)

        Saml::Elements::EncryptedAssertion.new(encrypted_data: encrypted_data, encrypted_keys: encrypted_key)
      end

      def decrypt_assertion(encrypted_assertion, private_key)
        encrypted_assertion_xml = encrypted_assertion.is_a?(Saml::Elements::EncryptedAssertion) ?
            encrypted_assertion.to_xml : encrypted_assertion.to_s
        encrypted_document      = Xmlenc::EncryptedDocument.new(encrypted_assertion_xml)

        Saml::Assertion.parse(encrypted_document.decrypt(private_key), single: true)
      end

      def verify_xml(message, raw_body)
        document = Xmldsig::SignedDocument.new(raw_body)

        signature_valid = document.validate do |signature, data, signature_algorithm|
          message.provider.verify(signature_algorithm, signature, data, message.signature.key_name)
        end

        raise Saml::Errors::SignatureInvalid.new unless signature_valid

        signed_node = document.signed_nodes.find { |node| node['ID'] == message._id }

        message.class.parse(signed_node.to_xml, single: true)
      end

      def download_metadata_xml(location)
        uri = URI.parse(location)

        http             = Net::HTTP.new(uri.host, uri.port)
        http.use_ssl     = uri.scheme == 'https'
        http.verify_mode = OpenSSL::SSL::VERIFY_PEER

        request = Net::HTTP::Get.new(uri.request_uri)

        response = http.request(request)
        if response.code == '200'
          response.body
        else
          raise Saml::Errors::MetadataDownloadFailed.new("Cannot download metadata for: #{location}: #{response.body}")
        end
      rescue Timeout::Error, Errno::EINVAL, Errno::ECONNRESET, EOFError, Net::HTTPBadResponse,
          Net::HTTPHeaderSyntaxError, Net::ProtocolError => error
        raise Saml::Errors::MetadataDownloadFailed.new("Cannot download metadata for: #{location}: #{error.message}")
      end
    end
  end
end
