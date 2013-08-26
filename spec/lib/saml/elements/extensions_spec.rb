require "spec_helper"

describe Saml::Elements::Extensions do

  describe "Optional fields" do
    [:entity_attributes].each do |field|
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

