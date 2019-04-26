require "spec_helper"

describe Saml::Elements::OrganizationName do

  it "has a tag" do
    expect(described_class.tag_name).to eq "OrganizationName"
  end

  it "has a namespace" do
    expect(described_class.namespace).to eq "md"
  end

  describe "required fields" do
    [:language].each do |field|
      it "responds the #{field} field" do
        expect(subject).to respond_to(field)
      end

      it "allows #{field} to blank" do
        subject.send("#{field}=", nil)
        expect(subject).not_to be_valid
      end
    end
  end

end
