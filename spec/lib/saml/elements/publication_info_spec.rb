require 'spec_helper'

describe Saml::Elements::PublicationInfo do
  let(:publication_info) { FactoryBot.build(:publication_info) }

  it "has a tag" do
    expect(described_class.tag_name).to eq "PublicationInfo"
  end

  it "has a namespace" do
    expect(described_class.namespace).to eq "mdrpi"
  end

  describe 'required fields' do
    [:publisher].each do |field|
      it "has the #{field} field" do
        expect(publication_info).to respond_to(field)
      end

      it "checks the presence of #{field}" do
        publication_info.send("#{field}=", nil)
        expect(publication_info).not_to be_valid
      end
    end
  end

  describe 'optional fields' do
    [:creation_instant, :publication_id].each do |field|
      it "has the #{field} field" do
        expect(publication_info).to respond_to(field)
      end

      it "allows #{field} to be blank" do
        publication_info.send("#{field}=", nil)
        expect(publication_info).to be_valid
      end
    end
  end
end
