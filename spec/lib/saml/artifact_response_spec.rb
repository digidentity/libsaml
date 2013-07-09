require 'spec_helper'

describe Saml::ArtifactResponse do

  let(:artifact_response) { build(:artifact_response) }

  it "Should be a StatusResponseType" do
    Saml::Response.ancestors.should include Saml::ComplexTypes::StatusResponseType
  end

  describe "Optional fields" do
    [:response].each do |field|
      it "should have the #{field} field" do
        artifact_response.should respond_to(field)
      end

      it "should allow #{field} to blank" do
        artifact_response.send("#{field}=", nil)
        artifact_response.should be_valid
        artifact_response.send("#{field}=", "")
        artifact_response.should be_valid
      end
    end
  end

  describe "parse" do
    let(:artifact_response_xml) { File.read(File.join('spec', 'fixtures', 'artifact_response.xml')) }
    let(:artifact_response) { Saml::ArtifactResponse.parse(artifact_response_xml, :single => true) }

    it "should parse the ArtifactResponse" do
      artifact_response.should be_a(Saml::ArtifactResponse)
    end

    it "should parse the Response" do
      artifact_response.response.should be_a(Saml::Response)
    end
  end

  describe ".to_xml" do
    let(:artifact_response_xml) { File.read(File.join('spec','fixtures','artifact_response.xml')) }
    let(:artifact_response) { Saml::ArtifactResponse.parse(artifact_response_xml, :single => true) }
    let(:new_artifact_response_xml) { artifact_response.to_xml }
    let(:new_artifact_response) { Saml::ArtifactResponse.parse(new_artifact_response_xml) }

    it "should generate a parseable XML document" do
      new_artifact_response.should be_a(Saml::ArtifactResponse)
    end
  end
end
