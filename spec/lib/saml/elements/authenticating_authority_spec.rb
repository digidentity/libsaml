require "spec_helper"

describe Saml::Elements::AuthenticatingAuthority do

  it "has a tag" do
    described_class.tag_name.should eq "AuthenticatingAuthority"
  end

  it "has a namespace" do
    described_class.namespace.should eq "saml"
  end

  it "can be parsed" do
    value = "AuthenticatingAuthorityValue"
    described_class.new(:value => value).to_xml.should eq "<?xml version=\"1.0\"?>\n<saml:AuthenticatingAuthority xmlns:saml=\"urn:oasis:names:tc:SAML:2.0:assertion\">#{value}</saml:AuthenticatingAuthority>\n"
  end

end
