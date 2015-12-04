require "spec_helper"

describe Saml::Elements::SAMLPExtensions do

  it 'includes the AttributeFetcher' do
    expect(described_class.ancestors).to include Saml::AttributeFetcher
  end

  it "has a tag" do
    described_class.tag_name.should eq "Extensions"
  end

  it "has a namespace" do
    described_class.namespace.should eq "samlp"
  end

  describe "optional fields" do
    [:attributes].each do |field|
      it "should have the #{field} field" do
        subject.should respond_to(field)
      end

      it "should allow #{field} to blank" do
        subject.send("#{field}=", nil)
        subject.should be_valid
      end
    end
  end
end
