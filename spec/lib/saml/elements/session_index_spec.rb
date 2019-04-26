require "spec_helper"

describe Saml::Elements::SessionIndex do

  it "has a tag" do
    expect(described_class.tag_name).to eq "SessionIndex"
  end

  it "has a namespace" do
    expect(described_class.namespace).to eq "samlp"
  end
end
