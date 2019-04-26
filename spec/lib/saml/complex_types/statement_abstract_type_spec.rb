require 'spec_helper'

describe Saml::ComplexTypes::StatementAbstractType do
  let(:statement_abstract_type_xml) { File.read('spec/fixtures/statement_abstract_type.xml') }

  after :each do
    described_class.types.clear
  end

  describe '.register_type' do
    it 'registers the type' do
      described_class.register_type 'statement', StatementDummy
      expect(described_class.types).to eq({'statement' => StatementDummy})
    end
  end

  describe 'parse' do
    describe 'without registered type' do
      subject { described_class.parse(statement_abstract_type_xml).first }

      it 'returns an instance of StatementAbstractType' do
        expect(subject).to be_a(described_class)
      end
    end

    describe 'with registered type' do
      before :each do
        described_class.register_type 'xacml-saml:XACMLAuthzDecisionStatementType', StatementDummy
      end

      subject { described_class.parse(statement_abstract_type_xml).first }

      it 'returns an instance of the registered type' do
        expect(subject).to be_a(StatementDummy)
      end

      it 'parses the authorization element' do
        expect(subject.authorization).to eq('allowed')
      end
    end
  end
end
