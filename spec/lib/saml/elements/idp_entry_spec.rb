require 'spec_helper'

describe Saml::Elements::IdpEntry do
  let(:idp_entry) { FactoryBot.build :idp_entry }

  describe 'optional fields' do
    [:name, :loc].each do |field|
      it "should respond to the '#{field}' field" do
        expect(subject).to respond_to(field)
      end
    end
  end

  describe 'required fields' do
    [:provider_id].each do |field|
      it "should have the #{field} field" do
        expect(subject).to respond_to(field)
      end

      it "should check the presence of #{field}" do
        subject.send("#{field}=", nil)
        expect(subject).not_to be_valid
      end
    end
  end

end
