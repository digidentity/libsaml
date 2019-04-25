require 'spec_helper'

describe Saml::Elements::ContactPerson do
  let(:contact_person) { FactoryBot.build(:contact_person) }

  describe "Required fields" do
    [:contact_type, :email_addresses, :telephone_numbers].each do |field|
      it "should have the #{field} field" do
        expect(contact_person).to respond_to(field)
      end

      it "should check the presence of #{field}" do
        contact_person.send("#{field}=", nil)
        expect(contact_person).not_to be_valid
      end
    end
  end

  describe "Optional fields" do
    [:company, :given_name, :sur_name].each do |field|
      it "should have the #{field} field" do
        expect(contact_person).to respond_to(field)
      end

      it "should allow #{field} to blank" do
        contact_person.send("#{field}=", nil)
        expect(contact_person).to be_valid
      end
    end
  end
end
