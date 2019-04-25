require "spec_helper"

describe Saml::Elements::MDExtensions do

  it "has a tag" do
    expect(described_class.tag_name).to eq "Extensions"
  end

  it "has a namespace" do
    expect(described_class.namespace).to eq "md"
  end

  describe "Optional fields" do
    [:entity_attributes, :publication_info].each do |field|
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

