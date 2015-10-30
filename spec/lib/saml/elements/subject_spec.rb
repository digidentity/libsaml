require 'spec_helper'

describe Saml::Elements::Subject do
  let(:subject) { FactoryGirl.build(:subject) }

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
        subject._name_id     = FactoryGirl.build(:name_id)
        subject.encrypted_id = FactoryGirl.build(:encrypted_id)
      end

      it 'adds an error on identifiers' do
        expect(subject).to have(1).error_on(:identifiers)
      end
    end

    context 'when one identifiers is set' do
      before do
        subject._name_id     = FactoryGirl.build(:name_id)
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
    [:subject_confirmation].each do |field|
      it "should have the #{field} field" do
        subject.should respond_to(field)
      end

      it "should check the presence of #{field}" do
        subject.send("#{field}=", nil)
        subject.should have(1).error_on(field)
      end
    end
  end

  describe "#parse" do
    let(:subject_xml) { File.read(File.join('spec','fixtures','artifact_response.xml')) }
    let(:subject) { Saml::Elements::Subject.parse(subject_xml, :single => true) }

    it "should create a Subject" do
      subject.should be_a(Saml::Elements::Subject)
    end

    it "should parse name_id" do
      subject.name_id.should == "s00000000:123456789"
    end

    it "should parse name_id_format" do
      subject.name_id_format.should == "urn:oasis:names:tc:SAML:2.0:nameid-format:persistent"
    end
  end
end
