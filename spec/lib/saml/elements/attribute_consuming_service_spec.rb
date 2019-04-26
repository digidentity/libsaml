require "spec_helper"

describe Saml::Elements::AttributeConsumingService do
  let(:attribute_consuming_service) { FactoryBot.build :attribute_consuming_service }

  describe "Required fields" do
    [:index].each do |field|
      it "should have the #{field} field" do
        expect(attribute_consuming_service).to respond_to(field)
      end

      it "should check the presence of #{field}" do
        attribute_consuming_service.send("#{field}=", nil)
        expect(attribute_consuming_service).not_to be_valid
      end
    end

    [:service_names, :requested_attributes].each do |field|
      it "should have the #{field} field" do
        expect(attribute_consuming_service).to respond_to(field)
      end

      it "should check the presence of #{field}" do
        attribute_consuming_service.send("#{field}=", nil)
        expect(attribute_consuming_service).not_to be_valid
        attribute_consuming_service.send("#{field}=", "")
        expect(attribute_consuming_service).not_to be_valid
      end
    end
  end

  describe "Optional fields" do
    [:service_descriptions].each do |field|
      it "should have the #{field} field" do
        expect(attribute_consuming_service).to respond_to(field)
      end

      it "should allow #{field} to blank" do
        attribute_consuming_service.send("#{field}=", nil)
        expect(attribute_consuming_service.errors.entries).to eq([]) #be_valid
        attribute_consuming_service.send("#{field}=", "")
        expect(attribute_consuming_service.errors.entries).to eq([]) #be_valid
      end
    end
  end
end
