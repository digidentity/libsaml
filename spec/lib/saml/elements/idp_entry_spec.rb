require 'spec_helper'

describe Saml::Elements::IdpEntry do
  let(:idp_entry) { FactoryGirl.build :idp_entry }

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
        subject.should respond_to(field)
      end

      it "should check the presence of #{field}" do
        subject.send("#{field}=", nil)
        subject.should_not be_valid
      end
    end
  end

end
