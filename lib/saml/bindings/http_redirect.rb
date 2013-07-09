module Saml
  module Bindings
    class HTTPRedirect
      class << self
        def create_url(request_or_response, options = {})
          options[:signature_algorithm] ||= 'http://www.w3.org/2000/09/xmldsig#rsa-sha1'
          new(request_or_response, options).create_url
        end

        def receive_message(http_request, options = {})
          options[:signature]           = Saml::Encoding.decode_64(http_request.params["Signature"] || "")
          options[:signature_algorithm] = http_request.params["SigAlg"]
          options[:relay_state]         = http_request.params["RelayState"]

          request_or_response = parse_request_or_response(options.delete(:type), http_request.params)

          redirect_binding = new(request_or_response, options)
          query_string     = URI.parse(http_request.url).query

          redirect_binding.verify_signature(query_string) if request_or_response.provider.authn_requests_signed?

          request_or_response
        end

        private

        def parse_request_or_response(type, params)
          message = decode_message(params["SAMLRequest"])

          Saml.parse_message(message, type)
        end

        def decode_message(message)
          Saml::Encoding.decode_gzip(Saml::Encoding.decode_64(message)).gsub("\n", "")
        end
      end

      attr_accessor :request_or_response, :signature_algorithm, :relay_state, :signature

      def initialize(request_or_response, options = {})
        @request_or_response = request_or_response
        @signature_algorithm = options[:signature_algorithm]
        @relay_state         = options[:relay_state]
        @signature           = options[:signature]
      end

      def verify_signature(query)
        unless request_or_response.provider.verify(signature_algorithm, signature, parse_signature_params(query))
          raise Saml::Errors::SignatureInvalid.new
        end
      end

      def create_url
        [request_or_response.destination, signed_params].join("?")
      end

      private


      def parse_signature_params(query)
        params = {}
        query.split(/[&;]/).each do |pairs|
          key, value  = pairs.split('=', 2)
          params[key] = value
        end

        relay_state = params["RelayState"] ? "&RelayState=#{params['RelayState']}" : ""
        "SAMLRequest=#{params['SAMLRequest']}#{relay_state}&SigAlg=#{params['SigAlg']}"
      end

      def encoded_message
        Saml::Encoding.encode_64(Saml::Encoding.encode_gzip(request_or_response.to_xml))
      end

      def encoded_params
        params.collect do |key, value|
          "#{key}=#{CGI.escape(value)}"
        end.join('&')
      end

      def params
        params = {}

        params["SAMLRequest"] = encoded_message
        params["RelayState"] = relay_state if relay_state
        params["SigAlg"] = signature_algorithm if signature_algorithm

        params
      end

      def signed_params
        signature = request_or_response.provider.sign(signature_algorithm, encoded_params)

        encoded_signature = CGI.escape(Saml::Encoding.encode_64(signature))

        "#{encoded_params}&Signature=#{encoded_signature}"
      end
    end
  end
end
