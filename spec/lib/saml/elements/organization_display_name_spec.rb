require "spec_helper"

describe Saml::Elements::OrganizationDisplayName do

  it "has a tag" do
    described_class.tag_name.should eq "OrganizationDisplayName"
  end

  it "has a namespace" do
    described_class.namespace.should eq "md"
  end

  describe "required fields" do
    [:language].each do |field|
      it "responds the #{field} field" do
        subject.should respond_to(field)
      end

      it "allows #{field} to blank" do
        subject.send("#{field}=", nil)
        subject.should_not be_valid
      end
    end
  end

end
