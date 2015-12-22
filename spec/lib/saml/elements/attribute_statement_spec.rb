require 'spec_helper'

describe Saml::Elements::AttributeStatement do
  let(:attribute_statement_xml) { File.read(File.join('spec', 'fixtures', 'attribute_statement.xml')) }
  let(:attribute_statement) { Saml::Elements::AttributeStatement.parse(attribute_statement_xml, :single => true) }

  let(:attribute_1) { FactoryGirl.build(:attribute, name: 'key_1') }
  let(:attribute_2) { FactoryGirl.build(:attribute, name: 'key_2') }

  it 'includes the AttributeFetcher' do
    expect(described_class.ancestors).to include Saml::AttributeFetcher
  end

  describe "Optional fields" do
    [:attributes, :encrypted_attributes].each do |field|
      it "should have the #{field} field" do
        attribute_statement.should respond_to(field)
      end

      it "should allow #{field} to blank" do
        attribute_statement.send("#{field}=", nil)
        attribute_statement.should be_valid
        attribute_statement.send("#{field}=", "")
        attribute_statement.should be_valid
      end
    end
  end

  describe '#parse' do
    it 'should create a AttributeStatement' do
      attribute_statement.should be_a(Saml::Elements::AttributeStatement)
    end

    it 'should parse attribute' do
      attribute_statement.attributes.first.should be_a(Saml::Elements::Attribute)
    end

    it 'should parse encrypted attributes' do
      attribute_statement.encrypted_attributes.first.should be_a Saml::Elements::EncryptedAttribute
    end
  end

  describe '#fetch_attribute' do
    it 'returns the attribute value content' do
      attribute_statement.fetch_attribute('urn:ServiceID').should == '1'
    end
  end

  describe '#fetch_attribute_value' do
    it 'returns the attribute value' do
      attribute_statement.fetch_attribute_value('urn:ServiceID').content.should == '1'
    end
  end

  describe '#attribute (DEPRECATED)' do
    before { attribute_statement.attributes = [ attribute_1, attribute_2 ] }

    it 'returns the attributes' do
      expect(attribute_statement.attribute).to match_array [ attribute_1, attribute_2 ]
    end

    it 'shows a deprecation warning' do
      expect { attribute_statement.attribute }.to output("[DEPRECATED] `attribute` please use #attributes\n").to_stderr
    end
  end

  describe '#attribute= (DEPRECATED)' do
    before { attribute_statement.attributes = nil }

    it 'sets the attributes' do
      aggregate_failures do
        expect(attribute_statement.attributes).to be_nil
        attribute_statement.attribute = [ attribute_1, attribute_2 ]
        expect(attribute_statement.attributes).to match_array [ attribute_1, attribute_2 ]
      end
    end

    it 'shows a deprecation warning' do
      expect { attribute_statement.attribute = [ attribute_1 ] }.to output("[DEPRECATED] `attribute=` please use #attributes=\n").to_stderr
    end
  end
end
