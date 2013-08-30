require 'spec_helper'

describe Saml::Elements::Attribute do
  it "includes the complex type AttributeType" do
    described_class.ancestors.should include Saml::ComplexTypes::AttributeType
  end
end
