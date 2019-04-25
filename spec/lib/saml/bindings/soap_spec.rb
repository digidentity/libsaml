require 'spec_helper'

describe Saml::Bindings::SOAP do
  let(:logout_request) { Saml::LogoutRequest.new(issue_instant: Time.at(0),
                                                 _id:           "1",
                                                 destination:   "http://example.com/logout") }
  let(:logout_response) { Saml::LogoutResponse.new(issue_instant: Time.at(0),
                                                   _id:           "1") }

  let(:response_xml) { described_class.create_response_xml(logout_response) }

  describe ".create_response_xml" do
    it "signs the response xml" do
      expect(Saml::LogoutResponse.parse(response_xml, single: true).signature.signature_value).not_to be_empty
    end

    it 'creates a notification' do
      expect {
        response_xml
      }.to notify_with('create_response')
    end
  end

  describe ".post_message" do

    it 'creates a notification' do
      expect {
        expect_any_instance_of(Net::HTTP).to receive(:request) do |request|
          @request = request
          double(:response, code: "200", body: response_xml)
        end
        @logout_response = described_class.post_message(logout_request, :logout_response)
      }.to notify_with('create_post', 'receive_response')
    end

    context "with valid response" do
      before :each do
        expect_any_instance_of(Net::HTTP).to receive(:request) do |request|
          @request = request
          double(:response, code: "200", body: response_xml)
        end
        @logout_response = described_class.post_message(logout_request, :logout_response)
      end

      it "creates a signed logout_request message" do
        logout_request = Saml::LogoutRequest.parse(@request.body, single: true)
        expect(logout_request).to be_a(Saml::LogoutRequest)
      end

      it "signs the artifact resolve" do
        logout_request = Saml::LogoutRequest.parse(@request.body, single: true)
        expect(logout_request.signature.signature_value).not_to be_blank
      end

      it "verifies the signature in the artifact response" do
        expect(@logout_response.errors[:signature]).to eq([])
      end

      it "sends the logout_request to the request destination" do
        uri = URI.parse(logout_request.destination)
        expect(Net::HTTP).to receive(:new).with(uri.host, uri.port, :ENV, nil, nil, nil).and_return double.as_null_object
        described_class.post_message(logout_request, :logout_response)
        expect(@request.path).to eq("/logout")
      end

      it "returns the logout_response" do
        expect(@logout_response).to be_a(Saml::LogoutResponse)
      end
    end

    context "with invalid signature" do
      before :each do
        expect_any_instance_of(Net::HTTP).to receive(:request) do |request|
          @request = request
          double(:request, code: "200", body: response_xml)
        end
      end

      it "adds an error if the signature is invalid" do
        expect(Saml::Util).to receive(:verify_xml).and_raise(Saml::Errors::SignatureInvalid)
        expect {
          described_class.post_message(logout_request, :logout_response)
        }.to raise_error(Saml::Errors::SignatureInvalid)
      end
    end
  end

  describe ".receive_message" do
    let(:request) { double(:request, body: StringIO.new(Saml::Util.sign_xml(logout_request, :soap))) } # Passenger uses StringIO for body
    let(:response) { described_class.receive_message(request, :logout_request) }

    context "with valid signature" do
      it "returns a logout request" do
        expect(response).to be_a(Saml::LogoutRequest)
      end

      it "verifies the signature in the artifact response" do
        expect(response.errors[:signature]).to eq([])
      end
    end

    context "with invalid signature" do
      it "adds an error if the signature is invalid" do
        expect(Saml::Util).to receive(:verify_xml).and_raise(Saml::Errors::SignatureInvalid)
        expect {
          response
        }.to raise_error(Saml::Errors::SignatureInvalid)
      end
    end

    it 'creates a notification' do
      expect {
        response
      }.to notify_with('receive_message')
    end
  end

end
