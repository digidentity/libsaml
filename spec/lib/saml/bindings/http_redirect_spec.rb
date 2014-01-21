require 'spec_helper'

describe Saml::Bindings::HTTPRedirect do
  let(:authn_request) { build(:authn_request, _id: "id", issuer: "https://sp.example.com", issue_instant: Time.at(0), destination: "http://example.com/sso") }
  let(:logout_response) { build(:logout_response, _id: "id", issuer: "https://sp.example.com", issue_instant: Time.at(0), destination: "http://example.com/sso") }

  let(:url) do
    described_class.create_url(authn_request,
                               relay_state:         "https//example.com/relay",
                               signature_algorithm: "http://www.w3.org/2000/09/xmldsig#rsa-sha1")
  end
  let(:params) { Saml::Util.parse_params(url) }

  describe ".create_url" do

    it 'creates a notification' do
      expect {
        url
      }.to notify_with('create_message')
    end

    it "parses the url from the destination" do
      url.should start_with("http://example.com/sso")
    end

    context "with a request message" do
      it "adds the object param" do
        params["SAMLRequest"].should == CGI.escape(described_class.new(authn_request).send(:encoded_message))
      end
    end

    context "with a response message" do
      let(:url) do
        described_class.create_url(logout_response,
                                   relay_state:         "https//example.com/relay",
                                   signature_algorithm: "http://www.w3.org/2000/09/xmldsig#rsa-sha1")
      end

      it "adds the object param" do
        params["SAMLResponse"].should == CGI.escape(described_class.new(logout_response).send(:encoded_message))
      end
    end

    it "adds the relay state" do
      params["RelayState"].should == CGI.escape("https//example.com/relay")
    end

    it "adds the signature algorithm" do
      params["SigAlg"].should == CGI.escape("http://www.w3.org/2000/09/xmldsig#rsa-sha1")
    end

    it "adds the signature" do
      params["Signature"].should == "OvRPA88Zn9hZmYuZAJ0gELY85rSGsz7AfoEXC1uGtLLzUy7wuyfbQj6uMc9X%0AGns9U9ogkQi2JmH1EZ91bYPdP9gQfrWNUnYHqa%2FDSjZAUvxdN4g6lJSprc46%0A6fgK%2BNMAhgrCX%2F60MFHqcQbhwZ9CzOWm22aajJvQnI%2B7EbMH8nw%3D"
    end

    context "with sha256" do
      let(:url) do
        described_class.create_url(authn_request,
                                   relay_state:         "https//example.com/relay",
                                   signature_algorithm: "http://www.w3.org/2001/04/xmldsig-more#rsa-sha256")
      end

      it "sets the signature algorithm" do
        params["SigAlg"].should == CGI.escape("http://www.w3.org/2001/04/xmldsig-more#rsa-sha256")
      end

      it "calculates the signature with sha256" do
        params["Signature"].should == "tdYHD67m1qU3MIGQML6FcLycpEcAAkL2gAS8JZpynMum8fdSV%2FDMuyALY3qa%0A%2BmOuWxW3heKnsM6h%2BshdLKdUooy4LvTFUNmSE7%2FW6QanO3%2F9ed7W8BYDdJPV%0AVUSvir9uZFWGplCRlaURTFYnmJxWUjzzrpgmSL%2Fs8dsuxvnjW1A%3D"
      end

    end

    context "with block" do
      let(:url) do
        described_class.create_url(authn_request,
                                   relay_state:         "https//example.com/relay",
                                   signature_algorithm: "http://www.w3.org/2000/09/xmldsig#rsa-sha1"
        )
      end

      it "uses the block to create the signature" do
        params["Signature"].should == "OvRPA88Zn9hZmYuZAJ0gELY85rSGsz7AfoEXC1uGtLLzUy7wuyfbQj6uMc9X%0AGns9U9ogkQi2JmH1EZ91bYPdP9gQfrWNUnYHqa%2FDSjZAUvxdN4g6lJSprc46%0A6fgK%2BNMAhgrCX%2F60MFHqcQbhwZ9CzOWm22aajJvQnI%2B7EbMH8nw%3D"
      end
    end
  end

  describe ".receive_message" do
    let(:parsed_params) do
      params.inject({}) { |h, (k, v)| h[k] = CGI.unescape(v); h }
    end

    let(:request) do
      double(:request, params: parsed_params, url: url)
    end

    it 'creates a notification' do
      expect {
        described_class.receive_message(request, type: :authn_request).should be_a(Saml::AuthnRequest)
      }.to notify_with('receive_message')
    end

    context "with signature" do
      it "verifies the params with a certificate" do
        described_class.receive_message(request, type: :authn_request).should be_a(Saml::AuthnRequest)
      end

      it "raises SignatureInvalid if verification fails" do
        Saml::BasicProvider.any_instance.stub(:verify).and_return(false)
        expect {
          described_class.receive_message(request, type: :authn_request).should be_nil
        }.to raise_error(Saml::Errors::SignatureInvalid)
      end
    end

    context "without signature" do
      it "raises no SignatureInvalid when AuthnRequestsSigned == false" do
        Saml::BasicProvider.any_instance.stub(:authn_requests_signed?).and_return(false)
        Saml::BasicProvider.any_instance.stub(:verify).and_return(false)
        described_class.receive_message(request, type: :authn_request).should be_a(Saml::AuthnRequest)
      end
    end
  end
end
