require "spec_helper"

describe Saml::Elements::RequestedAttribute do
  let(:requested_attribute) { FactoryGirl.build :requested_attribute }

  it "includes the complex type AttributeType" do
    described_class.ancestors.should include Saml::ComplexTypes::AttributeType
  end

  describe "Optional fields" do
    [:is_required].each do |field|
      it "should have the #{field} field" do
        requested_attribute.should respond_to(field)
      end
    end
  end

end
