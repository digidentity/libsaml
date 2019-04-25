require 'spec_helper'

describe Saml::Elements::Subject do
  let(:subject) { FactoryBot.build(:subject) }

  describe '#check_identifier' do
    context 'when no identifier is set' do
      before do
        subject._name_id     = nil
        subject.encrypted_id = nil
      end

      it 'adds an error on identifiers' do
        expect(subject).to have(1).error_on(:identifiers)
      end
    end

    context 'when multiple identifiers are set' do
      before do
        subject._name_id     = FactoryBot.build(:name_id)
        subject.encrypted_id = FactoryBot.build(:encrypted_id)
      end

      it 'adds an error on identifiers' do
        expect(subject).to have(1).error_on(:identifiers)
      end
    end

    context 'when one identifiers is set' do
      before do
        subject._name_id     = FactoryBot.build(:name_id)
        subject.encrypted_id = nil
      end

      it 'does NOT add an error on identifiers' do
        expect(subject).to have(0).error_on(:identifiers)
      end
    end
  end

  describe 'optional fields' do
    [:name_id, :encrypted_id].each do |field|
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

  describe "Required fields" do
    [:subject_confirmations].each do |field|
      it "should have the #{field} field" do
        expect(subject).to respond_to(field)
      end

      it "should check the presence of #{field}" do
        subject.send("#{field}=", nil)
        expect(subject).to have(1).error_on(field)
      end
    end
  end

  describe '.initialize' do
    subject { described_class.new(params) }

    context 'name_id is specified' do
      let(:params) { { name_id: 'TEST', name_id_format: 'format' } }

      it 'adds a name_id' do
        expect(subject._name_id).to be_a Saml::Elements::NameId
      end

      it '#name_id equals the given value' do
        expect(subject.name_id).to eq 'TEST'
      end

      it '#name_id_format equals the given format' do
        expect(subject.name_id_format).to eq 'format'
      end
    end

    context 'no name_id is specified' do
      let(:params) { {} }

      it '#name_id is nil' do
        expect(subject.name_id).to eq nil
      end

      it '#name_id_format is nil' do
        expect(subject.name_id_format).to eq nil
      end
    end
  end

  describe '#subject_confirmation' do
    let(:subject_confirmation_1) { FactoryBot.build(:subject_confirmation) }
    let(:subject_confirmation_2) { FactoryBot.build(:subject_confirmation) }

    before { subject.subject_confirmations = [subject_confirmation_1, subject_confirmation_2] }

    it 'returns the first subject confirmation element' do
      expect(subject.subject_confirmation).to eq subject_confirmation_1
    end
  end

  describe '#subject_confirmation=' do
    let(:subject_confirmation_1) { FactoryBot.build(:subject_confirmation) }
    let(:subject_confirmation_2) { FactoryBot.build(:subject_confirmation) }

    before { subject.subject_confirmations = [subject_confirmation_1] }

    it 'replaces the subject confirmations elements with the given element' do
      subject.subject_confirmation = subject_confirmation_2
      expect(subject.subject_confirmations).to match_array [subject_confirmation_2]
    end
  end

  describe "#parse" do
    let(:subject_xml) { File.read(File.join('spec','fixtures','artifact_response.xml')) }
    let(:subject) { Saml::Elements::Subject.parse(subject_xml, :single => true) }

    it "should create a Subject" do
      expect(subject).to be_a(Saml::Elements::Subject)
    end

    it "should parse name_id" do
      expect(subject.name_id).to eq("s00000000:123456789")
    end

    it "should parse name_id_format" do
      expect(subject.name_id_format).to eq("urn:oasis:names:tc:SAML:2.0:nameid-format:persistent")
    end
  end
end
