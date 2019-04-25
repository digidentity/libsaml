require 'spec_helper'

describe Saml::Elements::AudienceRestriction do

  let(:audience_restriction) { build(:audience_restriction) }

  describe "Optional fields" do
    [:audiences].each do |field|
      it "should have the #{field} field" do
        expect(audience_restriction).to respond_to(field)
      end

      it "should allow #{field} to blank" do
        audience_restriction.send("#{field}=", nil)
        expect(audience_restriction).to be_valid
        audience_restriction.send("#{field}=", "")
        expect(audience_restriction).to be_valid
      end
    end
  end

  describe '#audience' do
    context 'when there are audiences' do
      before { allow(audience_restriction).to receive(:audiences).and_return [ build(:audience, value: 'AuthorityProvider'), build(:audience, value: 'ServiceProvider') ] }

      it 'returns the first audience' do
        expect(audience_restriction.audience).to eq 'AuthorityProvider'
      end
    end

    context 'when there is only one audience' do
      before { allow(audience_restriction).to receive(:audiences).and_return [ build(:audience, value: 'ServiceProvider') ] }

      it 'returns the audience' do
        expect(audience_restriction.audience).to eq 'ServiceProvider'
      end
    end

    context 'when there are no audiences' do
      before { audience_restriction.audiences = nil }

      it 'returns nil' do
        expect(audience_restriction.audience).to be_nil
      end
    end
  end

  describe '#audience=' do
    let(:audience_restriction_xml) { File.read(File.join('spec','fixtures','artifact_response.xml')) }
    let(:audience_restriction) { Saml::Elements::AudienceRestriction.parse(audience_restriction_xml, :single => true) }

    it 'replaces the audience elements with the given element' do
      aggregate_failures do
        expect(audience_restriction.audiences.count).to eq 2
        expect(audience_restriction.audiences).to contain_exactly an_instance_of(Saml::Elements::Audience), an_instance_of(Saml::Elements::Audience)
        expect(audience_restriction.audiences.map(&:value)).to match_array ['ServiceProvider', 'AuthorityProvider']

        audience_restriction.audience = 'IdentityProvider'
        expect(audience_restriction.audiences.count).to eq 1
        expect(audience_restriction.audiences).to contain_exactly an_instance_of(Saml::Elements::Audience)
        expect(audience_restriction.audiences.map(&:value)).to match_array ['IdentityProvider']
      end
    end
  end

  describe "#parse" do
    let(:audience_restriction_xml) { File.read(File.join('spec','fixtures','artifact_response.xml')) }
    let(:audience_restriction) { Saml::Elements::AudienceRestriction.parse(audience_restriction_xml, :single => true) }

    it "should create an AudienceRestriction" do
      expect(audience_restriction).to be_a(Saml::Elements::AudienceRestriction)
    end

    it 'parses all the Audience elements' do
      expect(audience_restriction.audiences.count).to eq 2
    end

    it 'has the correct Audience values' do
      expect(audience_restriction.audiences.map(&:value)).to match_array ['ServiceProvider', 'AuthorityProvider']
    end
  end
end
