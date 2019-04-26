require 'spec_helper'

describe Saml::Elements::Evidence do

  describe "Required fields" do
    [:assertion].each do |field|
      it "should have the #{field} field" do
        expect(subject).to respond_to(field)
      end

      it "should check the presence of #{field}" do
        subject.send("#{field}=", nil)
        expect(subject).not_to be_valid
      end
    end
  end

  it "includes the complex type EvidenceType" do
    expect(described_class.ancestors).to include Saml::ComplexTypes::EvidenceType
  end

 describe "parse" do
    let(:xml) { File.read(File.join('spec', 'fixtures', 'evidence.xml')) }
    subject { Saml::Elements::Evidence.parse(xml, single: true) }

    it "should parse the AttributeQuery" do
      expect(subject).to be_a(Saml::Elements::Evidence)
    end

    it "has AttributeQueryType as an ancestor" do
      expect(described_class.ancestors).to include Saml::ComplexTypes::EvidenceType
    end

    it 'should have attributes' do
      expect(subject.assertion.first).to be_a(Saml::Assertion)
    end
  end
end
