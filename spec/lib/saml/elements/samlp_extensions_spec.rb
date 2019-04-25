require "spec_helper"

describe Saml::Elements::SAMLPExtensions do

  it 'includes the AttributeFetcher' do
    expect(described_class.ancestors).to include Saml::AttributeFetcher
  end

  it "has a tag" do
    expect(described_class.tag_name).to eq "Extensions"
  end

  it "has a namespace" do
    expect(described_class.namespace).to eq "samlp"
  end

  describe "optional fields" do
    [:attributes].each do |field|
      it "should have the #{field} field" do
        expect(subject).to respond_to(field)
      end

      it "should allow #{field} to blank" do
        subject.send("#{field}=", nil)
        expect(subject).to be_valid
      end
    end
  end
end
