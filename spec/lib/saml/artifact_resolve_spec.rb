require 'spec_helper'

describe Saml::ArtifactResolve do

  let(:artifact_resolve) { build(:artifact_resolve) }

  it "Should be a RequestAbstractType" do
    Saml::ArtifactResolve.ancestors.should include Saml::ComplexTypes::RequestAbstractType
  end

  describe "Artifact field" do
    it "should be available" do
      artifact_resolve.should respond_to(:artifact)
    end

    it "should be present" do
      artifact_resolve.artifact = nil
      artifact_resolve.should_not be_valid
    end

    it "Should be a Saml::Artifact" do
      artifact_resolve.artifact.should be_a(Saml::Artifact)
    end
  end

  describe "#initialize" do
    it "should convert a base64 encoded artifact to an artifact" do
      artifact_resolve = Saml::ArtifactResolve.new(artifact: Saml::Artifact.new.to_s)
      artifact_resolve.artifact.should be_a(Saml::Artifact)
    end

  end


  describe "#parse" do

    let(:artifact_resolve_xml) { File.read(File.join('spec','fixtures','artifact_resolve.xml')) }
    let(:artifact_resolve) { Saml::ArtifactResolve.parse(artifact_resolve_xml, :single => true) }

    it "should create an ArtifactResolve" do
      artifact_resolve.should be_a(Saml::ArtifactResolve)
    end

    it "should parse the artifact" do
      artifact_resolve.artifact.should be_a(Saml::Artifact)
    end
  end

  describe ".to_xml" do
    let(:artifact_resolve_xml) { File.read(File.join('spec','fixtures','artifact_resolve.xml')) }
    let(:artifact_resolve) { Saml::ArtifactResolve.parse(artifact_resolve_xml, :single => true) }
    let(:new_artifact_resolve_xml) { artifact_resolve.to_xml }
    let(:new_artifact_resolve) { Saml::ArtifactResolve.parse(new_artifact_resolve_xml) }

    it "should generate a parseable XML document" do
      new_artifact_resolve.should be_a(Saml::ArtifactResolve)
    end
  end
end
