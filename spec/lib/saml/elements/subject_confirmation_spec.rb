require 'spec_helper'

describe Saml::Elements::SubjectConfirmation do
  let(:subject_confirmation) { FactoryBot.build(:subject_confirmation) }

  describe "Required fields" do
    [:_method].each do |field|
      it "should have the #{field} field" do
        expect(subject_confirmation).to respond_to(field)
      end

      it "should check the presence of #{field}" do
        subject_confirmation.send("#{field}=", nil)
        expect(subject_confirmation).not_to be_valid
      end
    end
  end

  describe "#parse" do
    let(:subject_confirmation_xml) { File.read(File.join('spec', 'fixtures', 'artifact_response.xml')) }
    let(:subject_confirmation) { Saml::Elements::SubjectConfirmation.parse(subject_confirmation_xml, single: true) }

    it "should create a SubjectConfirmation" do
      expect(subject_confirmation).to be_a(Saml::Elements::SubjectConfirmation)
    end

    it "should parse method" do
      expect(subject_confirmation._method).to eq("urn:oasis:names:tc:SAML:2.0:cm:bearer")
    end

    it "should parse subject_confirmation_data" do
      expect(subject_confirmation.subject_confirmation_data).to be_a(Saml::Elements::SubjectConfirmationData)
    end
  end

  describe "initialize" do
    let(:subject_confirmation) do
      Saml::Elements::SubjectConfirmation.new(recipient: "recipient",
                                              in_response_to: "in_response_to")
    end

    it "should set the audience restriction if audience is present" do
      expect(subject_confirmation.subject_confirmation_data.recipient).to eq("recipient")
    end

    it "should set the in response to" do
      expect(subject_confirmation.subject_confirmation_data.in_response_to).to eq("in_response_to")
    end

    it "should set the default method to bearer" do
      expect(subject_confirmation._method).to eq(Saml::Elements::SubjectConfirmation::Methods::BEARER)
    end

  end
end
