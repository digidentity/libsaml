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
      Saml::LogoutResponse.parse(response_xml, single: true).signature.signature_value.should_not be_empty
    end
  end

  describe ".post_message" do
    context "with valid response" do
      before :each do
        Net::HTTP.any_instance.should_receive(:request) do |request|
          @request = request
          double(:response, code: "200", body: response_xml)
        end
        @logout_response = described_class.post_message(logout_request, :logout_response)
      end

      it "creates a signed logout_request message" do
        logout_request = Saml::LogoutRequest.parse(@request.body, single: true)
        logout_request.should be_a(Saml::LogoutRequest)
      end

      it "signs the artifact resolve" do
        logout_request = Saml::LogoutRequest.parse(@request.body, single: true)
        logout_request.signature.signature_value.should_not be_blank
      end

      it "verifies the signature in the artifact response" do
        @logout_response.errors[:signature].should == []
      end

      it "sends the logout_request to the request destination" do
        uri = URI.parse(logout_request.destination)
        Net::HTTP.should_receive(:new).with(uri.host, uri.port).and_return double.as_null_object
        described_class.post_message(logout_request, :logout_response)
        @request.path.should == "/logout"
      end

      it "returns the logout_response" do
        @logout_response.should be_a(Saml::LogoutResponse)
      end
    end

    context "with invalid signature" do
      before :each do
        Net::HTTP.any_instance.should_receive(:request) do |request|
          @request = request
          double(:request, code: "200", body: response_xml)
        end
        Saml::BasicProvider.any_instance.stub(:verify).and_return(false)
      end

      it "adds an error if the signature is invalid" do
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
        response.should be_a(Saml::LogoutRequest)
      end

      it "verifies the signature in the artifact response" do
        response.errors[:signature].should == []
      end
    end

    context "with invalid signature" do
      it "adds an error if the signature is invalid" do
        Saml::BasicProvider.any_instance.stub(:verify).and_return(false)
        expect {
          response
        }.to raise_error(Saml::Errors::SignatureInvalid)
      end
    end
  end

end
