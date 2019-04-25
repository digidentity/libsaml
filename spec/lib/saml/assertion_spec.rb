require 'spec_helper'

describe Saml::Assertion do
  let(:assertion) { FactoryBot.build(:assertion) }

  describe "Required fields" do
    [:_id, :version, :issue_instant, :issuer].each do |field|
      it "should have the #{field} field" do
        expect(assertion).to respond_to(field)
      end

      it "should check the presence of #{field}" do
        assertion.send("#{field}=", nil)
        expect(assertion).not_to be_valid
      end
    end
  end

  describe "Optional fields" do
    [:subject, :conditions, :authn_statement, :attribute_statement, :advice].each do |field|
      it "should have the #{field} field" do
        expect(assertion).to respond_to(field)
      end

      it "should allow #{field} to blank" do
        assertion.send("#{field}=", nil)
        expect(assertion).to be_valid
        assertion.send("#{field}=", "")
        expect(assertion).to be_valid
      end
    end
  end

  describe '#attribute_statement' do
    let(:attribute_statement_1) { FactoryBot.build(:attribute_statement) }
    let(:attribute_statement_2) { FactoryBot.build(:attribute_statement) }

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
    let(:attribute_statement_1) { FactoryBot.build(:attribute_statement) }
    let(:attribute_statement_2) { FactoryBot.build(:attribute_statement) }

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
      expect(assertion).to be_a(Saml::Assertion)
    end

    it "should parse the id" do
      expect(assertion._id).to eq("_93af655219464fb403b34436cfb0c5cb1d9a5502")
    end

    it "should parse the version" do
      expect(assertion.version).to eq("2.0")
    end

    it "should parse the issuer" do
      expect(assertion.issuer).to eq("Provider")
    end

    it "should parse Subject" do
      expect(assertion.subject).to be_a(Saml::Elements::Subject)
    end

    it "should parse Conditions" do
      expect(assertion.conditions).to be_a(Saml::Elements::Conditions)
    end

    it "should parse Advice" do
      expect(assertion.advice).to be_a(Saml::Elements::Advice)
    end

    it 'parses Statement elements' do
      aggregate_failures do
        expect(assertion.statements.size).to eq 1
        expect(assertion.statements.first).to be_a(Saml::ComplexTypes::StatementAbstractType)
      end
    end

    it 'parses AuthnStatement elements' do
      aggregate_failures do
        expect(assertion.authn_statement.size).to eq 1
        expect(assertion.authn_statement.first).to be_a(Saml::Elements::AuthnStatement)
      end
    end

    it 'parses AttributeStatement elements' do
      aggregate_failures do
        expect(assertion.attribute_statements.size).to eq 1
        expect(assertion.attribute_statements.first).to be_a(Saml::Elements::AttributeStatement)
      end
    end
  end

  describe "provider" do
    it "returns the provider based on the issuer" do
      assertion = Saml::Assertion.new(issuer: "https://sp.example.com")
      expect(assertion.provider).to eq(Saml.provider("https://sp.example.com"))
    end
  end

  describe ".initialize" do
    it "should set the subject name id if name_id specified" do
      assertion = Saml::Assertion.new(:name_id => "subject")
      expect(assertion.subject.name_id).to eq("subject")
    end

    it "should set the audience if the audience is specified" do
      assertion = Saml::Assertion.new(:audience => "audience")
      expect(assertion.conditions.audience_restriction.audience).to eq("audience")
    end

    it "should set the address if the specified" do
      assertion = Saml::Assertion.new(:address => "127.0.0.1")
      expect(assertion.authn_statement.subject_locality.address).to eq("127.0.0.1")
    end

    it "should set the address if the specified" do
      assertion = Saml::Assertion.new(:authn_context_class_ref => "authn_context")
      expect(assertion.authn_statement.authn_context.authn_context_class_ref).to eq("authn_context")
    end

    context 'subject is specified' do
      subject { described_class.new(subject: assertion_subject) }
      let(:assertion_subject) { ::Saml::Elements::Subject.new(value: 'TEST') }

      it 'should set #subject to the specified subject' do
        expect(subject.subject).to eq assertion_subject
      end
    end
  end

  describe "IssueInstant" do
    it "should not be valid if the issue instant is too old" do
      assertion.issue_instant = Time.now - Saml::Config.max_issue_instant_offset.minutes
      expect(assertion).to have(1).errors_on(:issue_instant)
    end
  end

  describe "Version" do
    it "should not be valid if the version is not allowed" do
      assertion.version = "invalid"
      expect(assertion).to have(1).errors_on(:version)
    end
  end

  describe 'add_attribute' do
    context 'when there is only one attribute statement' do
      it 'adds the attribute to the first attribute statement' do
        assertion.add_attribute('key', 'value')

        aggregate_failures do
          expect(assertion.attribute_statement.attributes.first.name).to eq 'key'
          expect(assertion.attribute_statement.attributes.first.attribute_values.first.content).to eq 'value'
        end
      end
    end

    context 'with an xsi type added' do
      it 'adds the attribute and includes the xsi type' do
        assertion.add_attribute('key', 'value', type: 'xsi:string')

        aggregate_failures do
          expect(assertion.attribute_statement.attributes.first.name).to eq 'key'
          expect(assertion.attribute_statement.attributes.first.attribute_values.first.content).to eq 'value'
          expect(assertion.attribute_statement.attributes.first.attribute_values.first.type).to eq 'xsi:string'
        end
      end
    end

    context 'with an attribute_options added' do
      it 'adds them to the attribute' do
        assertion.add_attribute(
          'key', 'value', {
            type: 'xsi:string'
          }, {
            friendly_name: 'eduPersonPrincipalName',
            format: 'urn:oasis:names:tc:SAML:2.0:attrname-format:uri'
          }
        )

        aggregate_failures do
          expect(assertion.attribute_statement.attributes.first.friendly_name).to eq 'eduPersonPrincipalName'
          expect(assertion.attribute_statement.attributes.first.format).to eq 'urn:oasis:names:tc:SAML:2.0:attrname-format:uri'
        end
      end
    end

    context 'when there are multiple attribute statements' do
      before { assertion.attribute_statements = [Saml::Elements::AttributeStatement.new, Saml::Elements::AttributeStatement.new] }

      it 'adds the attribute to the first attribute statement' do
        aggregate_failures do
          expect(assertion.attribute_statements.count).to eq 2
          expect(assertion.attribute_statements.first.attributes).to be_nil
          expect(assertion.attribute_statements.last.attributes).to be_nil

          assertion.add_attribute('key', 'value')
          expect(assertion.attribute_statements.first.attributes.first.name).to eq 'key'
          expect(assertion.attribute_statements.first.attributes.first.attribute_values.first.content).to eq 'value'
          expect(assertion.attribute_statements.last.attributes).to be_nil
        end
      end
    end

    context 'when Saml::Elements::NameId is given as value' do
      it 'adds them to the attribute' do
        assertion.add_attribute(
          'urn:oid:1.3.6.1.4.1.5923.1.1.1.10',
          Saml::Elements::NameId.new(
            name_qualifier: 'idp.example.com',
            sp_name_qualifier: 'idp.example.com',
            value: SecureRandom.hex(16)
          )
        )

        aggregate_failures do
          expect(assertion.attribute_statements.first.attributes.first.attribute_values.first.name_id).to be_instance_of Saml::Elements::NameId
          expect(assertion.attribute_statements.first.attributes.first.attribute_values.first.content).to be_blank
        end
      end
    end

    context 'when Array is given as value' do
      it 'adds them to the attribute' do
        assertion.add_attribute(
          'urn:oid:1.3.6.1.4.1.5923.1.5.1.1',
          ['group1', 'group2']
        )

        aggregate_failures do
          expect(assertion.attribute_statements.first.attributes.first.attribute_values.count).to eq 2
        end
      end
    end
  end

  describe 'fetch_attribute' do
    it 'returns the attribute from the attribute statement' do
      assertion.add_attribute('key', 'value')
      assertion.add_attribute('key2', 'value2')
      expect(assertion.fetch_attribute('key2')).to eq('value2')
    end

    it 'returns nil if attribute is not present' do
      expect(assertion.fetch_attribute('not_present')).to eq(nil)
    end
  end

  describe 'fetch_attribute_value' do
    it 'returns the attribute from the attribute statement' do
      assertion.add_attribute('key', 'value')
      assertion.add_attribute('key2', 'value2')
      expect(assertion.fetch_attribute_value('key2').content).to eq('value2')
    end

    it 'returns nil if attribute is not present' do
      expect(assertion.fetch_attribute_value('not_present')).to eq(nil)
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
      let(:attribute_1) { FactoryBot.build :attribute, name: 'key', attribute_value: 'value_1' }
      let(:attribute_2) { FactoryBot.build :attribute, name: 'key', attribute_value: 'value_2' }
      let(:attribute_3) { FactoryBot.build :attribute, name: 'key', attribute_value: 'value_3' }
      let(:attribute_4) { FactoryBot.build :attribute, name: 'another_key', attribute_value: 'value_4' }

      let(:attribute_statement_1) { FactoryBot.build :attribute_statement, attributes: [ attribute_1, attribute_2 ] }
      let(:attribute_statement_2) { FactoryBot.build :attribute_statement, attributes: [ attribute_3, attribute_4 ] }

      before { assertion.attribute_statements = [attribute_statement_1, attribute_statement_2] }

      it 'returns multiple attributes from multiple attribute statements' do
        expect(assertion.fetch_attributes('key')).to match_array %w(value_1 value_2 value_3)
      end

      it 'returns nil if attribute is not present' do
        expect(assertion.fetch_attribute('not_present')).to be_nil
      end
    end
  end

  describe 'fetch_attribute_values' do
    context 'when there is only one attribute statement' do
      it 'returns multiple attributes from the attribute statement' do
        assertion.add_attribute('key', 'value')
        assertion.add_attribute('key', 'value2')
        assertion.add_attribute('key2', 'value3')
        expect(assertion.fetch_attribute_values('key').map(&:content)).to match_array %w(value value2)
      end

      it 'returns nil if attribute is not present' do
        expect(assertion.fetch_attribute_values('not_present')).to be_nil
      end
    end

    context 'when there are multiple attribute statements' do
      let(:attribute_1) { FactoryBot.build :attribute, name: 'key', attribute_value: 'value_1' }
      let(:attribute_2) { FactoryBot.build :attribute, name: 'key', attribute_value: 'value_2' }
      let(:attribute_3) { FactoryBot.build :attribute, name: 'key', attribute_value: 'value_3' }
      let(:attribute_4) { FactoryBot.build :attribute, name: 'another_key', attribute_value: 'value_4' }

      let(:attribute_statement_1) { FactoryBot.build :attribute_statement, attributes: [ attribute_1, attribute_2 ] }
      let(:attribute_statement_2) { FactoryBot.build :attribute_statement, attributes: [ attribute_3, attribute_4 ] }

      before { assertion.attribute_statements = [attribute_statement_1, attribute_statement_2] }

      it 'returns multiple attributes from multiple attribute statements' do
        expect(assertion.fetch_attribute_values('key').map(&:content)).to match_array %w(value_1 value_2 value_3)
      end

      it 'returns nil if attribute is not present' do
        expect(assertion.fetch_attribute_values('not_present')).to be == []
      end
    end
  end
end
