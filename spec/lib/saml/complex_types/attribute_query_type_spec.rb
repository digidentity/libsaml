require 'spec_helper'

describe Saml::ComplexTypes::AttributeQueryType do
  subject { FactoryBot.build(:attribute_query_type_dummy) }

  describe "Required fields" do
    [:_id, :version, :issue_instant, :subject].each do |field|
      it "should have the #{field} field" do
        subject.should respond_to(field)
      end

      it "should check the presence of #{field}" do
        subject.send("#{field}=", nil)
        subject.should_not be_valid
      end
    end
  end

  describe "Optional fields" do
    [:destination, :issuer, :attributes].each do |field|
      it "should have the #{field} field" do
        subject.should respond_to(field)
      end

      it "should allow #{field} to blank" do
        subject.send("#{field}=", nil)
        subject.valid?
        subject.errors.entries.should == []
        subject.send("#{field}=", "")
        subject.valid?
        subject.errors.entries.should == []
      end
    end
  end

  it 'has no attributes' do
    expect(subject.attributes).to eq []
  end

  describe "parse" do
    let(:xml) { File.read(File.join('spec', 'fixtures', 'attribute_query.xml')) }
    subject { Saml::Elements::AttributeQuery.parse(xml, :single => true) }

    it "should parse the AttributeQuery" do
      expect(subject).to be_a(Saml::Elements::AttributeQuery)
    end

    it "has AttributeQueryType as an ancestor" do
      expect(described_class.ancestors).to include Saml::ComplexTypes::AttributeQueryType
    end

    it 'should have attributes' do
      expect(subject.attributes.first).to be_a(Saml::Elements::Attribute)
    end
  end
end
