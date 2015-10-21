require "spec_helper"

describe Saml::ComplexTypes::SubjectQueryAbstractType do
  subject { FactoryGirl.build(:subject_query_abstract_type_dummy) }

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
    [:destination, :issuer].each do |field|
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

  describe "parse" do
    let(:xml) { File.read(File.join('spec', 'fixtures', 'attribute_query.xml')) }
    subject { Saml::Elements::AttributeQuery.parse(xml, :single => true) }

    it "should parse the AttributeQuery" do
      expect(subject).to be_a(Saml::Elements::AttributeQuery)
    end

    it "has SubjectQueryAbstractType as an ancestor" do
      expect(described_class.ancestors).to include Saml::ComplexTypes::SubjectQueryAbstractType
    end

    it 'should have a subject' do
      expect(subject.subject).to be_a(Saml::Elements::Subject)
    end
  end
end
