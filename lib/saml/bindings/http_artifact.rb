module Saml
  module Bindings
    class HTTPArtifact

      class << self
        # @param [Saml::ArtifactResponse] artifact_response
        def create_response_xml(artifact_response)
          Saml::Util.sign_xml(artifact_response, :soap)
        end

        def create_url(location, artifact, options = {})
          uri   = URI.parse(location)
          query = [uri.query, "SAMLart=#{CGI.escape(artifact.to_s)}"]

          query << "RelayState=#{CGI.escape(options[:relay_state])}" if options[:relay_state]

          uri.query = query.compact.join("&")
          uri.to_s
        end

        def receive_message(request)
          raw_xml          = request.body.dup.read
          artifact_resolve = Saml::ArtifactResolve.parse(raw_xml, single: true)

          Saml::Util.verify_xml(artifact_resolve, raw_xml)
        end

        def resolve(request, location)
          artifact         = request.params["SAMLart"]
          artifact_resolve = Saml::ArtifactResolve.new(artifact: artifact, destination: location)

          response = Saml::Util.post(location, Saml::Util.sign_xml(artifact_resolve, :soap))

          if response.code == "200"
            artifact_response          = Saml::ArtifactResponse.parse(response.body, single: true)
            verified_artifact_response = Saml::Util.verify_xml(artifact_response, response.body)

            verified_artifact_response.response if artifact_response.success?
          end
        end
      end
    end
  end
end
