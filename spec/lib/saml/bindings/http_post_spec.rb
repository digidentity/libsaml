require 'spec_helper'

describe Saml::Bindings::HTTPPost do
  let(:response) do
    Saml::Response.new(issuer:        "https://idp.example.com",
                       destination:   "https://sp.example.com/sso",
                       issue_instant: Time.at(0),
                       _id:           "1")
  end

  describe ".create_form_attributes" do
    let(:form_attributes) { described_class.create_form_attributes(response, relay_state: "relay_state") }

    it "creates a hash with the destination as url" do
      expect(form_attributes[:location]).to eq(response.destination)
    end

    it "adds the relay_state" do
      expect(form_attributes[:variables]["RelayState"]).to eq("relay_state")
    end

    it "signs the document" do
      encoded_response = form_attributes[:variables]["SAMLResponse"]
      response         = Saml::Response.parse(Saml::Encoding.decode_64(encoded_response))

     expect(response.signature.signature_value).to be_present
    end

    it "sets the SAMLRequest variable if the message is a request" do
      form_attributes = described_class.create_form_attributes(Saml::AuthnRequest.new, relay_state: "relay_state")
      expect(form_attributes[:variables]["SAMLRequest"]).not_to be_blank
    end

    it 'creates a notification' do
      expect { form_attributes }.to notify_with('create_message')
    end

    context 'when skip_signature option given' do
      let(:form_attributes) do
        described_class.create_form_attributes(
          response,
          relay_state: "relay_state",
          skip_signature: true
        )
      end

      it "does not sign the document" do
        encoded_response = form_attributes[:variables]["SAMLResponse"]
        response         = Saml::Response.parse(Saml::Encoding.decode_64(encoded_response))
        expect(response.signature).not_to be_present
      end
    end
  end

  describe ".receive_message" do
    let(:form_attributes) { described_class.create_form_attributes(response, relay_state: "relay_state") }

    let(:request) do
      double(:request, params: form_attributes[:variables], url: "https://sp.example.com/sso")
    end

    let(:message) { described_class.receive_message(request, :response) }

    it "has no errors when signature is valid" do
      expect(message).to have(:no).errors_on(:signature)
    end

    it "it verifies the xml" do
      expect(Saml::Util).to receive(:verify_xml).and_raise(Saml::Errors::SignatureInvalid)
      expect {
        message
      }.to raise_error(Saml::Errors::SignatureInvalid)
    end

    it "returns the parsed message" do
      expect(message).to be_a(Saml::Response)
    end

    it "sets the actual destination on the message" do
      expect(message.actual_destination).to eq(request.url)
    end

    it 'creates a notification' do
      expect {
        message
      }.to notify_with('receive_message')
    end

    context 'When both `SAMLRequest` and `SAMLResponse` is nil in request params' do
      let(:request) { double(:request, params: {}, url: "https://sp.example.com/sso") }
      let(:message) { described_class.receive_message(request, :response) }

      it 'Raise Saml::Errors::InvalidParams' do
        expect { message }.to raise_error(Saml::Errors::InvalidParams, 'require params `SAMLRequest` or `SAMLResponse`')
      end
    end
  end
end
