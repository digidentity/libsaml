require "spec_helper"

describe Saml::ComplexTypes::EvidenceType do
  subject { Saml::Elements::Evidence.new }

  describe "Required fields" do
    [:assertion].each do |field|
      it "should have the #{field} field" do
        expect(subject).to respond_to(field)
      end

      it "should check the presence of #{field}" do
        subject.send("#{field}=", nil)
        expect(subject).not_to be_valid
      end
    end
  end
end
