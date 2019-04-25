require "spec_helper"

describe Saml::ComplexTypes::LocalizedNameType do
  let(:localized_name_type) { FactoryBot.build(:localized_name_type_dummy) }

  describe "Required fields" do
    [:language].each do |field|
      it "should have the #{field} field" do
        localized_name_type.should respond_to(field)
      end

      it "should check the presence of #{field}" do
        localized_name_type.send("#{field}=", nil)
        localized_name_type.should_not be_valid
      end
    end
  end

  describe "#parse" do
    let(:localized_name_type_xml) { File.read(File.join('spec','fixtures','metadata', 'identity_provider.xml')) }
    let(:localized_name_type) { Saml::Elements::OrganizationName.parse(localized_name_type_xml, :single => true) }

    it "should create a OrganizationName" do
      localized_name_type.should be_a(Saml::Elements::OrganizationName)
    end

  end
end
