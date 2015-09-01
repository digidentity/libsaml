require 'spec_helper'

describe Saml::ArtifactResponse do

  let(:artifact_response) { build(:artifact_response) }

  it "Should be a StatusResponseType" do
    Saml::Response.ancestors.should include Saml::ComplexTypes::StatusResponseType
  end

  describe "Optional fields" do
    [:response, :authn_request].each do |field|
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
    let(:artifact_response) { Saml::ArtifactResponse.parse(artifact_response_xml, :single => true) }

    context "when it contains a response" do
      let(:artifact_response_xml) { File.read(File.join('spec', 'fixtures', 'artifact_response.xml')) }

      it "should parse the ArtifactResponse" do
        artifact_response.should be_a(Saml::ArtifactResponse)
      end

      it "should parse the Response" do
        artifact_response.message.should be_a(Saml::Response)
      end
    end

    context "when it contains an authn request" do
      let(:artifact_response_xml) { File.read(File.join('spec', 'fixtures', 'artifact_response_with_authn_request.xml')) }

      it "should parse the ArtifactResponse" do
        artifact_response.should be_a(Saml::ArtifactResponse)
      end

      it "should parse the AuthnRequest" do
        artifact_response.message.should be_a(Saml::AuthnRequest)
      end
    end
  end

  describe ".to_xml" do
    let(:artifact_response) { Saml::ArtifactResponse.parse(artifact_response_xml, :single => true) }
    let(:new_artifact_response_xml) { artifact_response.to_xml }
    let(:new_artifact_response) { Saml::ArtifactResponse.parse(new_artifact_response_xml) }

    %w(artifact_response.xml artifact_response_with_authn_request.xml).each do |file|
      let(:artifact_response_xml) { File.read(File.join('spec', 'fixtures', file)) }

      it "should generate a parseable XML document" do
        new_artifact_response.should be_a(Saml::ArtifactResponse)
      end
    end
  end
end
