require "spec_helper"

describe Saml::Elements::AttributeConsumingService do
  let(:attribute_consuming_service) { FactoryBot.build :attribute_consuming_service }

  describe "Required fields" do
    [:index].each do |field|
      it "should have the #{field} field" do
        attribute_consuming_service.should respond_to(field)
      end

      it "should check the presence of #{field}" do
        attribute_consuming_service.send("#{field}=", nil)
        attribute_consuming_service.should_not be_valid
      end
    end

    [:service_names, :requested_attributes].each do |field|
      it "should have the #{field} field" do
        attribute_consuming_service.should respond_to(field)
      end

      it "should check the presence of #{field}" do
        attribute_consuming_service.send("#{field}=", nil)
        attribute_consuming_service.should_not be_valid
        attribute_consuming_service.send("#{field}=", "")
        attribute_consuming_service.should_not be_valid
      end
    end
  end

  describe "Optional fields" do
    [:service_descriptions].each do |field|
      it "should have the #{field} field" do
        attribute_consuming_service.should respond_to(field)
      end

      it "should allow #{field} to blank" do
        attribute_consuming_service.send("#{field}=", nil)
        attribute_consuming_service.errors.entries.should == [] #be_valid
        attribute_consuming_service.send("#{field}=", "")
        attribute_consuming_service.errors.entries.should == [] #be_valid
      end
    end
  end
end
