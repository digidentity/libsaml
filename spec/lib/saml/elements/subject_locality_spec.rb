require 'spec_helper'

describe Saml::Elements::SubjectLocality do
  let(:subject_locality) { FactoryGirl.build(:subject_locality) }

  describe "Optional fields" do
    [:address].each do |field|
      it "should have the #{field} field" do
        subject_locality.should respond_to(field)
      end

      it "should allow #{field} to blank" do
        subject_locality.send("#{field}=", nil)
        subject_locality.should be_valid
        subject_locality.send("#{field}=", "")
        subject_locality.should be_valid
      end
    end
  end

  describe "parse" do
    let(:subject_locality_xml) { File.read(File.join('spec', 'fixtures', 'artifact_response.xml')) }
    let(:subject_locality) { Saml::Elements::SubjectLocality.parse(subject_locality_xml, :single => true) }

    it "should parse the SubjectLocality" do
      subject_locality.should be_a(Saml::Elements::SubjectLocality)
    end

    it "should parse the subject_locality_class_ref" do
      subject_locality.address.should == "127.0.0.1"
    end
  end
end
