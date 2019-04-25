require "spec_helper"

describe Saml::Elements::NameId do

  it "has a tag" do
    expect(described_class.tag_name).to eq "NameID"
  end

  it "has a namespace" do
    expect(described_class.namespace).to eq "saml"
  end

  describe "optional fields" do
    [:format, :name_qualifier].each do |field|
      it "responds the #{field} field" do
        expect(subject).to respond_to(field)
      end

      it "allows #{field} to blank" do
        subject.send("#{field}=", nil)
        expect(subject).to be_valid
      end
    end
  end

end
