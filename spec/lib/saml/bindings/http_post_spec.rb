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
      form_attributes[:location].should == response.destination
    end

    it "adds the relay_state" do
      form_attributes[:variables]["RelayState"].should == "relay_state"
    end

    it "signs the document" do
      encoded_response = form_attributes[:variables]["SAMLResponse"]
      response         = Saml::Response.parse(Saml::Encoding.decode_64(encoded_response))

     response.signature.signature_value.should be_present
    end

    it "sets the SAMLRequest variable if the message is a request" do
      form_attributes = described_class.create_form_attributes(Saml::AuthnRequest.new, relay_state: "relay_state")
      form_attributes[:variables]["SAMLRequest"].should_not be_blank
    end

  end

  describe ".receive_message" do
    let(:form_attributes) { described_class.create_form_attributes(response, relay_state: "relay_state") }

    let(:request) do
      stub(params: form_attributes[:variables])
    end

    let(:message) { described_class.receive_message(request, :response) }

    it "has no errors when signature is valid" do
      message.should have(:no).errors_on(:signature)
    end

    it "raises SignatureInvalid if it is invalid" do
      Saml::BasicProvider.any_instance.stub(:verify).and_return(false)
      expect {
        message
      }.to raise_error(Saml::Errors::SignatureInvalid)
    end

    it "returns the parsed message" do
      message.should be_a(Saml::Response)
    end
  end
end
