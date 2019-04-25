require 'spec_helper'

describe Saml::Elements::Attribute do
  it "includes the complex type AttributeType" do
    expect(described_class.ancestors).to include Saml::ComplexTypes::AttributeType
  end
end
