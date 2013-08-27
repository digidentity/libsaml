require 'spec_helper'

describe Saml::Elements::EntitiesDescriptor do
  let(:entities_descriptor) { FactoryGirl.build(:entities_descriptor) }

  describe "Optional fields" do
    [:name, :valid_until, :cache_duration, :signature].each do |field|
      it "should have the #{field} field" do
        entities_descriptor.should respond_to(field)
      end

      it "should allow #{field} to be blank" do
        entities_descriptor.send("#{field}=", nil)
        entities_descriptor.should be_valid
      end
    end
  end

  describe "Required fields" do
    context "#entities_descriptors" do
      context "when there are no entity_descriptors" do
        before do
          entities_descriptor.entity_descriptors = []
        end

        it "should have at least one entities_descriptor" do
          entities_descriptor.entities_descriptors.should have_at_least(1).item
        end

        it "should allow entity_descriptors to be blank" do
          entities_descriptor.should be_valid
        end
      end
    end

    context "#entity_descriptors" do
      context "when there are no entities_descriptors" do
        before do
          entities_descriptor.entities_descriptors = []
        end

        it "should have at least one entity_descriptor" do
          entities_descriptor.entity_descriptors.should have_at_least(1).item
        end

        it "should allow entities_descriptors to be blank" do
          entities_descriptor.should be_valid
        end
      end
    end

    context "when there are no entities_descriptors or entity_descriptors" do
      it "should not be valid" do
        entities_descriptor.entities_descriptors = []
        entities_descriptor.entity_descriptors   = []
        entities_descriptor.should_not be_valid
      end
    end
  end

  describe "#add_signature" do
    it "adds a signature element to the entities descriptor" do
      entities_descriptor.add_signature
      parsed_entities_descriptor = described_class.parse(entities_descriptor.to_xml, single: true)
      parsed_entities_descriptor.signature.should be_a(Saml::Elements::Signature)
    end
  end
end
