require "spec_helper"

describe Saml::Elements::MDExtensions do

  it "has a tag" do
    described_class.tag_name.should eq "Extensions"
  end

  it "has a namespace" do
    described_class.namespace.should eq "md"
  end

  describe "Optional fields" do
    [:entity_attributes, :publication_info].each do |field|
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

