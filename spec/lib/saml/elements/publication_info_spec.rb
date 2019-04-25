require 'spec_helper'

describe Saml::Elements::PublicationInfo do
  let(:publication_info) { FactoryBot.build(:publication_info) }

  it "has a tag" do
    described_class.tag_name.should eq "PublicationInfo"
  end

  it "has a namespace" do
    described_class.namespace.should eq "mdrpi"
  end

  describe 'required fields' do
    [:publisher].each do |field|
      it "has the #{field} field" do
        publication_info.should respond_to(field)
      end

      it "checks the presence of #{field}" do
        publication_info.send("#{field}=", nil)
        publication_info.should_not be_valid
      end
    end
  end

  describe 'optional fields' do
    [:creation_instant, :publication_id].each do |field|
      it "has the #{field} field" do
        publication_info.should respond_to(field)
      end

      it "allows #{field} to be blank" do
        publication_info.send("#{field}=", nil)
        publication_info.should be_valid
      end
    end
  end
end
