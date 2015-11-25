require 'spec_helper'

class BaseDummy
  include Saml::Base

  tag 'tag'
end

describe BaseDummy do
  describe "parse override" do
    context "with a billion laughs" do
      xml = <<-XML
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE lolz [
<!ENTITY lol1 "&lol;&lol;&lol;&lol;&lol;&lol;&lol;&lol;&lol;&lol;">
<!ENTITY lol2 "&lol1;&lol1;&lol1;&lol1;&lol1;&lol1;&lol1;&lol1;&lol1;&lol1;">
<!ENTITY lol3 "&lol2;&lol2;&lol2;&lol2;&lol2;&lol2;&lol2;&lol2;&lol2;&lol2;">
<!ENTITY lol4 "&lol3;&lol3;&lol3;&lol3;&lol3;&lol3;&lol3;&lol3;&lol3;&lol3;">
<!ENTITY lol5 "&lol4;&lol4;&lol4;&lol4;&lol4;&lol4;&lol4;&lol4;&lol4;&lol4;">
<!ENTITY lol6 "&lol5;&lol5;&lol5;&lol5;&lol5;&lol5;&lol5;&lol5;&lol5;&lol5;">
<!ENTITY lol7 "&lol6;&lol6;&lol6;&lol6;&lol6;&lol6;&lol6;&lol6;&lol6;&lol6;">
<!ENTITY lol8 "&lol7;&lol7;&lol7;&lol7;&lol7;&lol7;&lol7;&lol7;&lol7;&lol7;">
<!ENTITY lol9 "&lol8;&lol8;&lol8;&lol8;&lol8;&lol8;&lol8;&lol8;&lol8;&lol8;">
]>
<samlp:AuthnRequest xmlns:samlp="urn:oasis:names:tc:SAML:2.0:protocol" IssueInstant="2013-08-25T14:31:07Z" AssertionConsumerServiceURL="test:&lol4;"></samlp:AuthnRequest>
      XML

      it "raises an Saml::Errors::HackAttack for entity expansion has grown too large" do
        expect { BaseDummy.parse(xml) }.to raise_error RuntimeError, 'entity expansion has grown too large'
      end
    end

    it "sets the from_xml flag" do
      BaseDummy.parse("<tag></tag>", single: true).from_xml?.should be true
    end

    it "raises an error if the message cannot be parsed" do
      expect {
        BaseDummy.parse("invalid")
      }.to raise_error(Saml::Errors::UnparseableMessage)
    end

    it "raises an error if the message is nil" do
      expect {
        BaseDummy.parse(nil)
      }.to raise_error(Saml::Errors::UnparseableMessage)
    end

    it 'raises an error when a method does not exist' do
      ActiveSupport::XmlMini_REXML.should_receive(:parse).and_raise(NoMethodError)
      expect {
        BaseDummy.parse('unknown')
      }.to raise_error(Saml::Errors::UnparseableMessage)
    end

    it "preserves the original value" do
      cert = OpenSSL::X509::Certificate.new(Base64.decode64(%{MIIG7jCCBNagAwIBAgICC0cwDQYJKoZIhvcNAQELBQAwTzELMAkGA1UEBhMC
                          TkwxGTAXBgNVBAoTEERpZ2lkZW50aXR5IEIuVi4xJTAjBgNVBAMTHERpZ2lk
                          ZW50aXR5IFNlcnZpY2VzIENBIC0gRzIwHhcNMTUwNzA2MDkyNjEwWhcNMTgw
                          NzA2MDkyNjEwWjCBrTEdMBsGA1UEBRMUMDAwMDAwMDQwMDMyMTQzNDUwMDEx
                          CzAJBgNVBAYTAk5MMRUwEwYDVQQIDAxadWlkLUhvbGxhbmQxFjAUBgNVBAcM
                          DSdzLUdyYXZlbmhhZ2UxDzANBgNVBAoMBkxvZ2l1czEUMBIGA1UECwwLZUhl
                          cmtlbm5pbmcxKTAnBgNVBAMMIHNpZ24xLnRlc3RuZXR3b3JrLmVoZXJrZW5u
                          aW5nLm5sMIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAxXQLuhT+
                          3c5iH6UNa4nwmQP8E1zmtyd7qH5wzcYUCelJZlNiEWtRhxozLs5aIwzB+C0D
                          Yt69dRavWNQv/KUAe4mZFUawKwY7WCXg/xvGOdMpmvq3llvz1tuhf3IjLJkB
                          g1ECOaSTyEN5B5JueD23Ee0YBuF0rZC/nXekjddHSw3zJp73AbcUMT0LYEoU
                          W4LMaiswWcnhCb85n9OOqzPTDfVQ3hBNZiC7xjfIoO36EUocCuhvSPsrUfu+
                          F5H8F17hhPVppkgT4fxjkvjrXMsyIoQQozLlqWEL0Lpd9B4xGfr1/ofrbp/D
                          KJ/xCQMTfw/W1f/j3SKUDnzQGufj5PSxAwIDAQABo4ICczCCAm8wHwYDVR0j
                          BBgwFoAUm2OFT7EJVRFqGuc+Hh0ASduW880wRwYIKwYBBQUHAQEEOzA5MDcG
                          CCsGAQUFBzABhitodHRwOi8vb2NzcC5kaWdpZGVudGl0eS5ldS9MNC9zZXJ2
                          aWNlcy9vY3NwMA4GA1UdDwEB/wQEAwIDqDAdBgNVHSUEFjAUBggrBgEFBQcD
                          AQYIKwYBBQUHAwIwgeoGA1UdIASB4jCB3zCB3AYKYIQQAYdrAQIFBjCBzTAv
                          BggrBgEFBQcCARYjaHR0cDovL3BraS5kaWdpZGVudGl0eS5ldS92YWxpZGF0
                          aWUwgZkGCCsGAQUFBwICMIGMGoGJSGV0IHRvZXBhc3NpbmdzZ2ViaWVkIHZh
                          biBkaXQgY2VydGlmaWNhYXQgaXMgY29uZm9ybSBkZSBhbGdlbWVuZSB2b29y
                          d2FhcmRlbiBlbiBjZXJ0aWZpY2F0ZSBwcmFjdGljZSBzdGF0ZW1lbnQgbml2
                          ZWF1IEw0IHZhbiBEaWdpZGVudGl0eS4wHQYDVR0OBBYEFCTTeO99qmXuq5w0
                          x77iy+kAE+2aMEQGA1UdHwQ9MDswOaA3oDWGM2h0dHA6Ly9wa2kuZGlnaWRl
                          bnRpdHkuZXUvTDQvc2VydmljZXMvbGF0ZXN0Q1JMLmNybDCBgQYDVR0RBHow
                          eKBUBgorBgEEAYI3FAIDoEYMRDEuMi4zLjQsMi4xNi41MjguMS4xMDAzLjEu
                          My41LjgtMWFhMGVkZWEtNTc2MC00YzI5LWI1YTAtODljNGViZjMxZWFigiBz
                          aWduMS50ZXN0bmV0d29yay5laGVya2VubmluZy5ubDANBgkqhkiG9w0BAQsF
                          AAOCAgEAepm2lFPdcB9SA1gGFhSDBbu74LXbocJoYYakYLLSfhh4xaH4oRnp
                          HmrSV2/XAk8AdXvZp9fJYjUUvYLjYQ315IKmykAXd5xSLisiZ9ustMqTOWOY
                          kxk5box/zurkc5gvHbX0ppcE6xmXOPg4fGcza90AoLRS/vt1j7VFMjcFVBjH
                          tlJGUmmNH2Y/s/HxtDxuTmRcE5rQDfFRvMQVPIL1qazcwUvnObdJYSWQPGsX
                          OD1R/53yKBI5jx7b5wOow/uwvJK3aQvsMPyOnbu4vLcvVFXJcjR71gVivKkY
                          9u3Su8yzPCfCfMGn5nDsgPlPoQJjgiT0sCxAcCQjA8REQx5G/ngMLI/KOszi
                          eUj7PPHATyVQj+HKvj2tQz6hQWhRMC8JR4mGcpEANyCrdYwSL6IuTnocNb/2
                          nq+guXJPUeD24kRgxjd/pn5zGNx2tec5CtZDp7FRGY5udbI5yLm6PlEsC+Sn
                          oEf/4YXx5S21K0SJ7+6APwDPZgaxx5reUX0oRTpVwuZOLr2iCgmTvh+Pl9LN
                          CYRzH2EzG8lfvndXnNaQeaxa7YpOZo/HFcQH6zo+2rVkJq6HoLhBqvJ+vIDZ
                          9N3oqQY2H5zRUCOgZuR+PL3kyW2H/2B3LC5w8Er0zkBVMSVI8PwpR7w0K/cV
                          0eBFEfTV1rvqPmY69ToVmdkJFDa3Dys=}))


      new_assertion = Saml::Assertion.parse(File.read('spec/fixtures/signed_with_inserted.xml'), single: true)

      new_response          = build(:response, assertion: new_assertion, _id: Saml.generate_id)
      new_artifact_response = build(:artifact_response, response: new_response, _id: Saml.generate_id)
      new_artifact_response.add_signature

      new_artifact_response.use_original(new_assertion)

      xml_with_space = new_artifact_response.to_xml

      document   = Xmldsig::SignedDocument.new(xml_with_space)
      document.sign do |data, signature_algorithm|
        new_artifact_response.provider.sign(signature_algorithm, data)
      end

      expect(document.signatures.first.valid?(new_artifact_response.provider.certificate)).to be_truthy
      expect(document.signatures.last.valid?(cert)).to be_truthy
    end
  end
end
