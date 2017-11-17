require 'spec_helper'

describe Saml::Bindings::HTTPRedirect do
  let(:authn_request) { build(:authn_request, _id: "id", issuer: "https://sp.example.com", issue_instant: Time.at(0), destination: "http://example.com/sso") }
  let(:logout_response) { build(:logout_response, _id: "id", issuer: "https://sp.example.com", issue_instant: Time.at(0), destination: "http://example.com/sso") }
  let(:logout_response_idp) { build(:logout_response, _id: "id", issuer: "https://idp.example.com", issue_instant: Time.at(0), destination: "https://sp.example.com/sso/logout") }


  def get_url(request = authn_request)
    described_class.create_url(request,
                               relay_state:         "https//example.com/relay",
                               signature_algorithm: "http://www.w3.org/2000/09/xmldsig#rsa-sha1")
  end

  let(:url) { get_url }
  let(:params) { Saml::Util.parse_params(url) }

  describe ".create_url" do

    let(:sha1_signature_mri) { "cbNvXpgIAEfTOzjHqjicwo3OrxdQrlz8EVUKaSVTYcfDKmdivP7ggbSLKofAB4P25TUmIQVdLhJF4GlKtaVTnp34rU%2B1PIklydvcR5KPlYbN3DPGU%2FewbbzkoRO8aHG78kOOiPa9tVhjCFgu5ji6h%2FPz%2FS%2FyEXfJUndt501O%2FLQ%3D" }
    let(:sha1_signature_jruby) { "2vXj7953U%2FPO%2FId%2FFhIZdNpOnPIMMnuIUcpxQ%2F5%2BTN1PDghQW3uqdIIPM8oQPtYEjgj8jIoRHAGbkyZQX5bUEiAZA7y1Dj1awvRKIna225ggZaxYsTGBpc5av2Kj4sLSo%2BRKTF6thfncT3MfbnVO6wo9YzJVPk2YuKX2Ko5fB00%3D" }
    let(:sha256_signature_mri) { "dxItbidLlxvem97mHEhRJfPfRNwUu%2FTJJD5scdak4zwOORVJ9XglaDQyE2zy1EnRvnkUE8uJ7%2FrEjEGwWQ7hdgdAAmgD4pE5XmE8%2F13LaiysXvfb6Vnb%2Byf6%2BggJKNd1laz4oMSR8vnchzh68oPNet7tNuvD2eszy2v5sQ7r4ew%3D" }
    let(:sha256_signature_jruby) { "svplMNOBflxICRoxZo1FCSg0xSPtmBQeZSraKQ7eFNHFFsuEwy2uOJ2RA6ZleY%2FQIYH%2BWTDUn2kLaR98QjyYp5zrC27SaDvCA80alUxFS%2F65alLr3Jq4DGN%2BP5QqxypN04pM%2F12EhqnF7TGkIl%2B1sciVjGnQgK0DRC7Jvt%2BlpWg%3D" }

    it 'creates a notification' do
      expect {
        url
      }.to notify_with('create_message')
    end

    it "parses the url from the destination" do
      url.should start_with("http://example.com/sso")
    end

    it "uses the correct delimiter when there are existing parameters in the destination URL" do
     request = build(:authn_request, _id: "id", issuer: "https://sp.example.com", issue_instant: Time.at(0), destination: "http://example.com/sso?idpid=1234asdf")
     url = get_url(request)

     params = CGI.parse(URI.parse(url).query)

     expect(url.count('?')).to eq(1)
     expect(params['idpid']).to eq(['1234asdf'])
     expect(params['SAMLRequest']).to_not be_blank
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

    # NOTE The xmlmapper gem will order XML namespaces differently under JRuby and MRI
    it "adds the signature" do
      if RUBY_ENGINE == 'jruby'
        params["Signature"].should == sha1_signature_jruby
      else
        params["Signature"].should == sha1_signature_mri
      end
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

      # NOTE The xmlmapper gem will order XML namespaces differently under JRuby and MRI
      it "calculates the signature with sha256" do
        if RUBY_ENGINE == 'jruby'
          params["Signature"].should == sha256_signature_jruby
        else
          params["Signature"].should == sha256_signature_mri
        end
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
        if RUBY_ENGINE == 'jruby'
          params["Signature"].should == sha1_signature_jruby
        else
          params["Signature"].should == sha1_signature_mri
        end
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
      let(:parsed_params) do
        params.except('Signature', 'SigAlg').inject({}) { |h, (k, v)| h[k] = CGI.unescape(v); h }
      end

      it "raises no SignatureInvalid when AuthnRequestsSigned == false" do
        Saml::BasicProvider.any_instance.stub(:authn_requests_signed?).and_return(false)
        described_class.receive_message(request, type: :authn_request).should be_a(Saml::AuthnRequest)
      end

      it "raises no SignatureMissing when AuthnRequestsSigned == true" do
        Saml::BasicProvider.any_instance.stub(:authn_requests_signed?).and_return(true)
        expect { described_class.receive_message(request, type: :authn_request) }.to raise_error(Saml::Errors::SignatureMissing)
      end

      context "with an IDP issued message" do
        let(:url) do
          described_class.create_url(logout_response_idp,
                                     relay_state:         "https//example.com/relay",
                                     signature_algorithm: "http://www.w3.org/2000/09/xmldsig#rsa-sha1")
        end

        let(:response) do
          double(:response, params: parsed_params, url: url)
        end

        it 'parses the message correctly' do
          described_class.receive_message(response, type: :logout_response).should be_a(Saml::LogoutResponse)
        end
      end
    end
  end
end
