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
<samlp:AuthnRequest xmlns:samlp="urn:oasis:names:tc:SAML:2.0:protocol" IssueInstant="2013-08-25T14:31:07Z" AssertionConsumerServiceURL="test:&lol9;"></samlp:AuthnRequest>
      XML

      it "raises an Saml::Errors::HackAttack for entity expansion has grown too large" do
        expect{ BaseDummy.parse(xml) }.to raise_error RuntimeError, 'entity expansion has grown too large'
      end
    end

    it "sets the from_xml flag" do
      BaseDummy.parse("<tag></tag>", single: true).from_xml?.should be true
    end

    it "raises an error if the message cannot be parsed" do
      expect {
        BaseDummy.parse("invalid")
      }.to raise_error(REXML::ParseException)
    end

    it "raises an error if the message is nil" do
      expect {
        BaseDummy.parse(nil)
      }.to raise_error(Saml::Errors::UnparseableMessage)
    end
  end
end
