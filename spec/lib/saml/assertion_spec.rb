require 'spec_helper'

describe Saml::Assertion do
  let(:assertion) { FactoryGirl.build(:assertion) }

  describe "Required fields" do
    [:_id, :version, :issue_instant, :issuer].each do |field|
      it "should have the #{field} field" do
        assertion.should respond_to(field)
      end

      it "should check the presence of #{field}" do
        assertion.send("#{field}=", nil)
        assertion.should_not be_valid
      end
    end
  end

  describe "Optional fields" do
    [:subject, :conditions, :authn_statement, :attribute_statement, :advice].each do |field|
      it "should have the #{field} field" do
        assertion.should respond_to(field)
      end

      it "should allow #{field} to blank" do
        assertion.send("#{field}=", nil)
        assertion.should be_valid
        assertion.send("#{field}=", "")
        assertion.should be_valid
      end
    end
  end

  describe '#attribute_statement' do
    let(:attribute_statement_1) { FactoryGirl.build(:attribute_statement) }
    let(:attribute_statement_2) { FactoryGirl.build(:attribute_statement) }

    context 'when there are attribute statements' do
      before { subject.attribute_statements = [attribute_statement_1, attribute_statement_2] }

      it 'returns the first attribute statement' do
        expect(subject.attribute_statement).to eq attribute_statement_1
      end
    end

    context 'when there is only one attribute statement' do
      before { subject.attribute_statements = [attribute_statement_1] }

      it 'returns the attribute statement' do
        expect(subject.attribute_statement).to eq attribute_statement_1
      end
    end

    context 'when there are no attribute statements' do
      before { subject.attribute_statements = nil }

      it 'returns nil' do
        expect(subject.attribute_statement).to be_nil
      end
    end
  end

  describe '#attribute_statement=' do
    let(:attribute_statement_1) { FactoryGirl.build(:attribute_statement) }
    let(:attribute_statement_2) { FactoryGirl.build(:attribute_statement) }

    before { subject.attribute_statements = [attribute_statement_1] }

    it 'replaces the attribute statement elements with the given element' do
      subject.attribute_statement = attribute_statement_2
      expect(subject.attribute_statements).to match_array [attribute_statement_2]
    end
  end

  describe "parse" do
    let(:assertion_xml) { File.read(File.join('spec', 'fixtures', 'artifact_response.xml')) }
    let(:assertion) { Saml::Assertion.parse(assertion_xml, :single => true) }

    it "should parse the Assertion" do
      assertion.should be_a(Saml::Assertion)
    end

    it "should parse the id" do
      assertion._id.should == "_93af655219464fb403b34436cfb0c5cb1d9a5502"
    end

    it "should parse the version" do
      assertion.version.should == "2.0"
    end

    it "should parse the issuer" do
      assertion.issuer.should == "Provider"
    end

    it "should parse Subject" do
      assertion.subject.should be_a(Saml::Elements::Subject)
    end

    it "should parse Conditions" do
      assertion.conditions.should be_a(Saml::Elements::Conditions)
    end

    it "should parse Advice" do
      expect(assertion.advice).to be_a(Saml::Elements::Advice)
    end

    it "should parse AuthnStatement" do
      assertion.authn_statement.first.should be_a(Saml::Elements::AuthnStatement)
    end

    it "should parse AttributeStatement" do
      assertion.attribute_statement.should be_a(Saml::Elements::AttributeStatement)
    end

  end

  describe "provider" do
    it "returns the provider based on the issuer" do
      assertion = Saml::Assertion.new(issuer: "https://sp.example.com")
      assertion.provider.should == Saml.provider("https://sp.example.com")
    end
  end

  describe ".initialize" do
    it "should set the subject name id if name_id specified" do
      assertion = Saml::Assertion.new(:name_id => "subject")
      assertion.subject.name_id.should == "subject"
    end

    it "should set the audience if the audience is specified" do
      assertion = Saml::Assertion.new(:audience => "audience")
      assertion.conditions.audience_restriction.audience.should == "audience"
    end

    it "should set the address if the specified" do
      assertion = Saml::Assertion.new(:address => "127.0.0.1")
      assertion.authn_statement.subject_locality.address.should == "127.0.0.1"
    end

    it "should set the address if the specified" do
      assertion = Saml::Assertion.new(:authn_context_class_ref => "authn_context")
      assertion.authn_statement.authn_context.authn_context_class_ref.should == "authn_context"
    end
  end

  describe "IssueInstant" do
    it "should not be valid if the issue instant is too old" do
      assertion.issue_instant = Time.now - Saml::Config.max_issue_instant_offset.minutes
      assertion.should have(1).errors_on(:issue_instant)
    end
  end

  describe "Version" do
    it "should not be valid if the version is not allowed" do
      assertion.version = "invalid"
      assertion.should have(1).errors_on(:version)
    end
  end

  describe 'add_attribute' do
    context 'when there is only one attribute statement' do
      it 'adds the attribute to the first attribute statement' do
        assertion.add_attribute('key', 'value')

        aggregate_failures do
          expect(assertion.attribute_statement.attribute.first.name).to eq 'key'
          expect(assertion.attribute_statement.attribute.first.attribute_values.first.content).to eq 'value'
        end
      end
    end

    context 'when there are multiple attribute statements' do
      before { assertion.attribute_statements = [Saml::Elements::AttributeStatement.new, Saml::Elements::AttributeStatement.new] }

      it 'adds the attribute to the first attribute statement' do
        aggregate_failures do
          expect(assertion.attribute_statements.count).to eq 2
          expect(assertion.attribute_statements.first.attribute).to be_nil
          expect(assertion.attribute_statements.last.attribute).to be_nil

          assertion.add_attribute('key', 'value')
          expect(assertion.attribute_statements.first.attribute.first.name).to eq 'key'
          expect(assertion.attribute_statements.first.attribute.first.attribute_values.first.content).to eq 'value'
          expect(assertion.attribute_statements.last.attribute).to be_nil
        end
      end
    end
  end

  describe 'fetch_attribute' do
    it 'returns the attribute from the attribute statement' do
      assertion.add_attribute('key', 'value')
      assertion.add_attribute('key2', 'value2')
      assertion.fetch_attribute('key2').should == 'value2'
    end

    it 'returns nil if attribute is not present' do
      assertion.fetch_attribute('not_present').should == nil
    end
  end

  describe 'fetch_attributes' do
    context 'when there is only one attribute statement' do
      it 'returns multiple attributes from the attribute statement' do
        assertion.add_attribute('key', 'value')
        assertion.add_attribute('key', 'value2')
        assertion.add_attribute('key2', 'value3')
        expect(assertion.fetch_attributes('key')).to match_array %w(value value2)
      end

      it 'returns nil if attribute is not present' do
        expect(assertion.fetch_attribute('not_present')).to be_nil
      end
    end

    context 'when there are multiple attribute statements' do
      let(:attribute_1) { FactoryGirl.build :attribute, name: 'key', attribute_value: 'value_1' }
      let(:attribute_2) { FactoryGirl.build :attribute, name: 'key', attribute_value: 'value_2' }
      let(:attribute_3) { FactoryGirl.build :attribute, name: 'key', attribute_value: 'value_3' }
      let(:attribute_4) { FactoryGirl.build :attribute, name: 'another_key', attribute_value: 'value_4' }

      let(:attribute_statement_1) { FactoryGirl.build :attribute_statement, attribute: [ attribute_1, attribute_2 ] }
      let(:attribute_statement_2) { FactoryGirl.build :attribute_statement, attribute: [ attribute_3, attribute_4 ] }

      before { assertion.attribute_statements = [attribute_statement_1, attribute_statement_2] }

      it 'returns multiple attributes from multiple attribute statements' do
        expect(assertion.fetch_attributes('key')).to match_array %w(value_1 value_2 value_3)
      end

      it 'returns nil if attribute is not present' do
        expect(assertion.fetch_attribute('not_present')).to be_nil
      end
    end
  end
end
