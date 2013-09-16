require "spec_helper"

describe Saml::Elements::NameId do

  it "has a tag" do
    described_class.tag_name.should eq "NameID"
  end

  it "has a namespace" do
    described_class.namespace.should eq "saml"
  end

  describe "optional fields" do
    [:format, :name_qualifier].each do |field|
      it "responds the #{field} field" do
        subject.should respond_to(field)
      end

      it "allows #{field} to blank" do
        subject.send("#{field}=", nil)
        subject.should be_valid
      end
    end
  end

end
