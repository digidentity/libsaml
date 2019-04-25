require 'spec_helper'

describe Saml::Elements::Organization do
  let(:organization) { FactoryBot.build(:organization) }

  describe "Required fields" do
    [:organization_names, :organization_display_names, :organization_urls].each do |field|
      it "should have the #{field} field" do
        organization.should respond_to(field)
      end

      it "should check the presence of #{field}" do
        organization.send("#{field}=", nil)
        organization.should_not be_valid
      end
    end
  end
end
