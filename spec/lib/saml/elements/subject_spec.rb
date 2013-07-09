require 'spec_helper'

describe Saml::Elements::Subject do
  let(:subject) { FactoryGirl.build(:subject) }

  describe "Required fields" do
    [:name_id, :subject_confirmation].each do |field|
      it "should have the #{field} field" do
        subject.should respond_to(field)
      end

      it "should check the presence of #{field}" do
        subject.send("#{field}=", nil)
        subject.should_not be_valid
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
  end
end
