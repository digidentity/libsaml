require "spec_helper"

describe Saml::Elements::AuthenticatingAuthority do

  it "has a tag" do
    expect(described_class.tag_name).to eq "AuthenticatingAuthority"
  end

  it "has a namespace" do
    expect(described_class.namespace).to eq "saml"
  end

  it "can be parsed" do
    value = "AuthenticatingAuthorityValue"
    expect(described_class.new(value: value).to_xml).to eq "<?xml version=\"1.0\"?>\n<saml:AuthenticatingAuthority xmlns:saml=\"urn:oasis:names:tc:SAML:2.0:assertion\">#{value}</saml:AuthenticatingAuthority>\n"
  end

end
