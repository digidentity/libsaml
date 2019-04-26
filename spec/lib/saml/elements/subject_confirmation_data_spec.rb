require 'spec_helper'

describe Saml::Elements::SubjectConfirmationData do
  let(:subject_confirmation_data) { FactoryBot.build(:subject_confirmation_data) }

  describe "Required fields" do
    [:not_on_or_after, :recipient, :in_response_to].each do |field|
      it "should have the #{field} field" do
        expect(subject_confirmation_data).to respond_to(field)
      end

      it "should check the presence of #{field}" do
        subject_confirmation_data.send("#{field}=", nil)
        expect(subject_confirmation_data).not_to be_valid
      end
    end
  end

  describe "#parse" do
    let(:subject_confirmation_data_xml) { File.read(File.join('spec','fixtures','artifact_response.xml')) }
    let(:subject_confirmation_data) { Saml::Elements::SubjectConfirmationData.parse(subject_confirmation_data_xml, single: true) }

    it "should create a SubjectConfirmation" do
      expect(subject_confirmation_data).to be_a(Saml::Elements::SubjectConfirmationData)
    end

    it "should parse not_on_or_after" do
      expect(subject_confirmation_data.not_on_or_after).to eq(Time.parse("2011-08-31T08:51:05Z"))
    end

    it "should parse recipient" do
      expect(subject_confirmation_data.recipient).to eq("https://sp.example.com/assertion_consumer")
    end

    it "should parse in_response_to" do
      expect(subject_confirmation_data.in_response_to).to eq("_13603a6565a69297e9809175b052d115965121c8")
    end

  end
end
