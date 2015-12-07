require "spec_helper"

describe Saml::Elements::SessionIndex do

  it "has a tag" do
    described_class.tag_name.should eq "SessionIndex"
  end

  it "has a namespace" do
    described_class.namespace.should eq "samlp"
  end
end
