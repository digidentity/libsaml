require 'spec_helper'

describe Saml::Bindings::HTTPArtifact do
  let(:artifact) { Saml::Artifact.new }
  let(:artifact_resolve) { Saml::ArtifactResolve.new(artifact:      artifact,
                                                     issuer:        "https://sp.example.com",
                                                     issue_instant: Time.at(0),
                                                     _id:           "1") }
  let(:artifact_response) { Saml::ArtifactResponse.new(issue_instant: Time.at(0),
                                                       _id:           "1",
                                                       status_value:  Saml::TopLevelCodes::SUCCESS,
                                                       response:      Saml::Response.new(issue_instant: Time.at(0),
                                                                                         status_value:  Saml::TopLevelCodes::SUCCESS,
                                                                                         _id:           "1"),
                                                       issuer:        "https://idp.example.com",) }
  let(:response_xml) { described_class.create_response_xml(artifact_response) }
  let(:response) { described_class.create_response(artifact_response) }

  describe ".create_response_xml" do

    it "signs the response xml" do
      Saml::ArtifactResponse.parse(response_xml, single: true).signature.signature_value.should_not be_empty
    end

    it 'creates a notification' do
      expect {
        response
      }.to notify_with('create_response')
    end
  end

  describe '.create_response' do
    it 'returns the response xml' do
      response[:xml].should == response_xml
    end

    it 'returns the content type' do
      response[:content_type].should == "text/xml"
    end
  end

  describe ".create_url" do
    context "with relay state" do
      it "creates a artifact url given a location and an artifact" do
        url = described_class.create_url("http://www.example.com/artifact", artifact, relay_state: "http://relay.example.com")
        url.should == "http://www.example.com/artifact?SAMLart=#{CGI.escape(artifact.to_s)}&RelayState=#{CGI.escape("http://relay.example.com")}"
      end
    end
    context "without relay state" do
      it "creates a artifact url given a location and an artifact" do
        url = described_class.create_url("http://www.example.com/artifact?param=value", artifact)
        url.should == "http://www.example.com/artifact?param=value&SAMLart=#{CGI.escape(artifact.to_s)}"
      end
    end
  end

  describe ".receive_message" do

    let(:body) do
      StringIO.new(Saml::Util.sign_xml(artifact_resolve)) # Passenger uses StringIO for body
    end

    let(:request) { double(:request, body: body) }
    let(:message) { described_class.receive_message(request) }

    it "returns an artifact resolve" do
      message.should be_a(Saml::ArtifactResolve)
    end

    it "verifies the signature in the artifact resolve" do
      message.errors[:signature].should == []
    end

    it "adds an error if the signature is invalid" do
      Saml::BasicProvider.any_instance.stub(:verify).and_return(false)
      expect {
        message
      }.to raise_error(Saml::Errors::SignatureInvalid)
    end

    it 'creates a notification' do
      expect {
        message
      }.to notify_with('receive_message')
    end
  end

  describe ".resolve" do
    let(:identity_provider) { Saml.provider(Saml.current_provider.entity_id) }
    let(:request) { double(:request, params: {"SAMLart" => CGI.escape(Saml::Artifact.new.to_s)}) }

    context 'notifications' do
      it 'creates a notification' do
        Net::HTTP.any_instance.should_receive(:request) do |request|
          @request = request
          double(:response, code: "200", body: response_xml)
        end

        expect {
          described_class.resolve(request, identity_provider.artifact_resolution_service_url)
        }.to notify_with('create_post', 'receive_response')
      end
    end

    context "with valid response" do
      before :each do
        Net::HTTP.any_instance.should_receive(:request) do |request|
          @request = request
          double(:response, code: "200", body: response_xml)
        end
        @artifact_response = described_class.resolve(request, identity_provider.artifact_resolution_service_url)
      end

      it "creates a signed artifact_resolve message" do
        artifact_resolve = Saml::ArtifactResolve.parse(@request.body, single: true)
        artifact_resolve.should be_a(Saml::ArtifactResolve)
      end

      it "signs the artifact resolve" do
        artifact_resolve = Saml::ArtifactResolve.parse(@request.body, single: true)
        artifact_resolve.signature.signature_value.should_not be_blank
      end

      it "sends the artifact_resolve to the identity provider" do
        uri = URI.parse(identity_provider.artifact_resolution_service_url)
        Net::HTTP.should_receive(:new).with(uri.host, uri.port).and_return double.as_null_object
        described_class.resolve(request, identity_provider.artifact_resolution_service_url)
        @request.path.should == "/sso/resolve_artifact"
      end

      it "returns the response" do
        @artifact_response.should be_a(Saml::Response)
      end
    end

    context "with invalid response" do
      before :each do
        Net::HTTP.any_instance.should_receive(:request) do |request|
          @request = request
          double(:response, code: "200", body: response_xml)
        end
      end

      it "adds an error if the signature is invalid" do
        Saml::BasicProvider.any_instance.stub(:verify).and_return(false)
        expect {
          described_class.resolve(request, identity_provider.artifact_resolution_service_url)
        }.to raise_error(Saml::Errors::SignatureInvalid)
      end

      it ''
    end
  end
end
