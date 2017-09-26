require 'spec_helper'

describe Saml::Elements::Scoping do
  let(:idp_entry) { FactoryGirl.build :scoping }

  describe 'optional fields' do
    [:idp_list].each do |field|
      it "should respond to the '#{field}' field" do
        expect(subject).to respond_to(field)
      end
    end
  end

  describe '#parse_xml' do
    let(:authn_request_xml) { File.read(File.join('spec', 'fixtures', 'authn_request.xml')) }
    let(:scoping)           { Saml::Elements::Scoping.parse(authn_request_xml, single: true) }

    it 'should create a new Saml::Elements::Scoping' do
      expect(scoping).to be_a(Saml::Elements::Scoping)
    end

    it 'should parse the IDP list' do
      expect(scoping.idp_list).to be_a(Saml::Elements::IdpList)
    end
  end

end
