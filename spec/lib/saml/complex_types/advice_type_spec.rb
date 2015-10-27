require 'spec_helper'

describe Saml::ComplexTypes::AdviceType do
  subject { FactoryGirl.build(:advice_type_dummy) }

  describe 'optional fields' do
    [:assertions].each do |field|
      it "responds to the #{field} field" do
        expect(subject).to respond_to(field)
      end

      it "allows #{field} to blank" do
        subject.send("#{field}=", nil)
        expect(subject.errors.entries).to match_array []
        subject.send("#{field}=", '')
        expect(subject.errors.entries).to match_array []
      end
    end
  end

  describe '#parse' do
    let(:advice_type_xml) { File.read(File.join('spec','fixtures','advice_type.xml')) }
    let(:advice_type)     { Saml::Elements::Advice.parse(advice_type_xml, single: true) }

    it 'parses all the Assertions' do
      expect(advice_type.assertions.count).to eq 2
    end

    it 'has the correct Assertion type' do
      expect(advice_type.assertions.first).to be_a(Saml::Assertion)
    end
  end

end
