require 'spec_helper'

describe Saml::Elements::IdpList do
  let(:idp_list) { FactoryBot.build :idp_list }

  describe 'required fields' do
    [:idp_entries].each do |field|
      it "should have the #{field} field" do
        subject.should respond_to(field)
      end

      it "should check the presence of #{field}" do
        subject.send("#{field}=", nil)
        subject.should_not be_valid
      end
    end
  end

  describe '#idp_entries' do
    it 'returns an empty array if no IDP entries have been registered' do
      expect(subject.idp_entries).to eq []
    end
  end

  describe '#parse_xml' do
    let(:authn_request_xml) { File.read(File.join('spec', 'fixtures', 'authn_request.xml')) }
    let(:idp_list)          { Saml::Elements::IdpList.parse(authn_request_xml, single: true) }

    it 'should create a new Saml::Elements::IdpList' do
      expect(idp_list).to be_a(Saml::Elements::IdpList)
    end

    it 'should parse the IDP entries' do
      aggregate_failures do
        expect(idp_list.idp_entries.count).to eq 2

        expect(idp_list.idp_entries.first).to be_a(Saml::Elements::IdpEntry)
        expect(idp_list.idp_entries.first.provider_id).to eq 'provider-id-1'
        expect(idp_list.idp_entries.first.name).to eq 'Provider name 1'
        expect(idp_list.idp_entries.first.loc).to eq 'https://idp1.example.com'

        expect(idp_list.idp_entries.second).to be_a(Saml::Elements::IdpEntry)
        expect(idp_list.idp_entries.second.provider_id).to eq 'provider-id-2'
        expect(idp_list.idp_entries.second.name).to eq 'Provider name 2'
        expect(idp_list.idp_entries.second.loc).to eq 'https://idp2.example.com'
      end
    end
  end

end
