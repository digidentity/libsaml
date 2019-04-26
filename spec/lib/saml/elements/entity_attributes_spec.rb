require "spec_helper"

describe Saml::Elements::EntityAttributes do

  describe "Optional fields" do
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
