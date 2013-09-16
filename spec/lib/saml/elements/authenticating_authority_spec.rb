require "spec_helper"

describe Saml::Elements::AuthenticatingAuthority do

  it "has a tag" do
    described_class.tag_name.should eq "AuthenticatingAuthority"
  end

  it "has a namespace" do
    described_class.namespace.should eq "saml"
  end

end
