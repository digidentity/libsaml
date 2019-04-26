require "spec_helper"

describe Saml::Elements::RequestedAttribute do
  let(:requested_attribute) { FactoryBot.build :requested_attribute }

  it "includes the complex type AttributeType" do
    expect(described_class.ancestors).to include Saml::ComplexTypes::AttributeType
  end

  describe "Optional fields" do
    [:is_required].each do |field|
      it "should have the #{field} field" do
        expect(requested_attribute).to respond_to(field)
      end
    end
  end

end
