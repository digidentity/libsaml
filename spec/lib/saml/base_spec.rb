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

    it 'preserves the original message' do
      assertion         = build(:assertion, _id: Saml.generate_id)
      response          = build(:response, assertion: assertion, _id: Saml.generate_id)
      artifact_response = build(:artifact_response, response: response, _id: Saml.generate_id)

      # x509certificate = OpenSSL::X509::Certificate.new(artifact_response.provider.certificate)
      assertion.add_signature
      # assertion.signature.key_info = Saml::Elements::KeyInfo.new(x509certificate.to_pem)
      artifact_response.add_signature

      xml_no_space = artifact_response.to_xml(formatted: true)

      document     = Xmldsig::SignedDocument.new(xml_no_space)
      xml_no_space = document.sign do |data, signature_algorithm|
        artifact_response.provider.sign(signature_algorithm, data)
      end

      parsed_artifact_response = Saml::ArtifactResponse.parse(xml_no_space, single: true)
      new_assertion            = parsed_artifact_response.response.assertion

      new_response          = build(:response, assertion: new_assertion, _id: Saml.generate_id)
      new_artifact_response = build(:artifact_response, response: new_response, _id: Saml.generate_id)
      new_artifact_response.add_signature

      xml_with_space = new_artifact_response.to_xml()

      document   = Xmldsig::SignedDocument.new(xml_with_space)
      signed_xml = document.sign do |data, signature_algorithm|
        artifact_response.provider.sign(signature_algorithm, data)
      end

      Saml::Util.verify_xml(Saml::ArtifactResponse.parse(signed_xml, single: true), signed_xml)
    end
  end
end
