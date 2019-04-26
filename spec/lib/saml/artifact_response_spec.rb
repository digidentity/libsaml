require 'spec_helper'

describe Saml::ArtifactResponse do

  let(:artifact_response) { build(:artifact_response) }

  it "Should be a StatusResponseType" do
    expect(Saml::Response.ancestors).to include Saml::ComplexTypes::StatusResponseType
  end

  describe "Optional fields" do
    [:response, :authn_request].each do |field|
      it "should have the #{field} field" do
        expect(artifact_response).to respond_to(field)
      end

      it "should allow #{field} to blank" do
        artifact_response.send("#{field}=", nil)
        expect(artifact_response).to be_valid
        artifact_response.send("#{field}=", "")
        expect(artifact_response).to be_valid
      end
    end
  end

  describe "parse" do
    let(:artifact_response) { Saml::ArtifactResponse.parse(artifact_response_xml, single: true) }

    context "when it contains a response" do
      let(:artifact_response_xml) { File.read(File.join('spec', 'fixtures', 'artifact_response.xml')) }

      it "should parse the ArtifactResponse" do
        expect(artifact_response).to be_a(Saml::ArtifactResponse)
      end

      it "should parse the Response" do
        expect(artifact_response.message).to be_a(Saml::Response)
      end
    end

    context "when it contains an authn request" do
      let(:artifact_response_xml) { File.read(File.join('spec', 'fixtures', 'artifact_response_with_authn_request.xml')) }

      it "should parse the ArtifactResponse" do
        expect(artifact_response).to be_a(Saml::ArtifactResponse)
      end

      it "should parse the AuthnRequest" do
        expect(artifact_response.message).to be_a(Saml::AuthnRequest)
      end
    end

    context "when it contains a signed message but is not signed itself" do
      let(:artifact_response_xml) { File.read(File.join('spec', 'fixtures', 'unsigned_artifact_response_with_signed_authn_request.xml')) }

      it "the ArtifactResponse should not have a signature" do
        expect(artifact_response.signature).to be_nil
      end

      it "the AuthnRequest should have a signature" do
        expect(artifact_response.message.signature).to be_a(Saml::Elements::Signature)
      end
    end
  end

  describe ".to_xml" do
    let(:artifact_response) { Saml::ArtifactResponse.parse(artifact_response_xml, single: true) }
    let(:new_artifact_response_xml) { artifact_response.to_xml }
    let(:new_artifact_response) { Saml::ArtifactResponse.parse(new_artifact_response_xml) }

    %w(artifact_response.xml artifact_response_with_authn_request.xml).each do |file|
      let(:artifact_response_xml) { File.read(File.join('spec', 'fixtures', file)) }

      it "should generate a parseable XML document" do
        expect(new_artifact_response).to be_a(Saml::ArtifactResponse)
      end
    end

    context "when it contains a signed message but is not signed itself" do
      let(:artifact_response_xml) { File.read(File.join('spec', 'fixtures', 'unsigned_artifact_response_with_signed_authn_request.xml')) }

      it "the ArtifactResponse should not have a signature" do
        expect(artifact_response.signature).to be_nil
      end

      it "the AuthnRequest should have a signature" do
        expect(artifact_response.message.signature).to be_a(Saml::Elements::Signature)
      end
    end
  end
end
