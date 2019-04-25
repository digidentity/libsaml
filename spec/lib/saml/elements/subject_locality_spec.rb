require 'spec_helper'

describe Saml::Elements::SubjectLocality do
  let(:subject_locality) { FactoryBot.build(:subject_locality) }

  describe "Optional fields" do
    [:address].each do |field|
      it "should have the #{field} field" do
        expect(subject_locality).to respond_to(field)
      end

      it "should allow #{field} to blank" do
        subject_locality.send("#{field}=", nil)
        expect(subject_locality).to be_valid
        subject_locality.send("#{field}=", "")
        expect(subject_locality).to be_valid
      end
    end
  end

  describe "parse" do
    let(:subject_locality_xml) { File.read(File.join('spec', 'fixtures', 'artifact_response.xml')) }
    let(:subject_locality) { Saml::Elements::SubjectLocality.parse(subject_locality_xml, single: true) }

    it "should parse the SubjectLocality" do
      expect(subject_locality).to be_a(Saml::Elements::SubjectLocality)
    end

    it "should parse the subject_locality_class_ref" do
      expect(subject_locality.address).to eq("127.0.0.1")
    end
  end
end
