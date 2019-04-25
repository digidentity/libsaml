require 'spec_helper'

describe Saml::ArtifactResolve do

  let(:artifact_resolve) { build(:artifact_resolve) }

  it "Should be a RequestAbstractType" do
    expect(Saml::ArtifactResolve.ancestors).to include Saml::ComplexTypes::RequestAbstractType
  end

  describe "Artifact field" do
    it "should be available" do
      expect(artifact_resolve).to respond_to(:artifact)
    end

    it "should be present" do
      artifact_resolve.artifact = nil
      expect(artifact_resolve).to be_invalid
    end

    it "Should be a Saml::Artifact" do
      expect(artifact_resolve.artifact).to be_a(Saml::Artifact)
    end
  end

  describe "#initialize" do
    it "should convert a base64 encoded artifact to an artifact" do
      artifact_resolve = Saml::ArtifactResolve.new(artifact: Saml::Artifact.new.to_s)
      expect(artifact_resolve.artifact).to be_a(Saml::Artifact)
    end

  end


  describe "#parse" do

    let(:artifact_resolve_xml) { File.read(File.join('spec','fixtures','artifact_resolve.xml')) }
    let(:artifact_resolve) { Saml::ArtifactResolve.parse(artifact_resolve_xml, :single => true) }

    it "should create an ArtifactResolve" do
      expect(artifact_resolve).to be_a(Saml::ArtifactResolve)
    end

    it "should parse the artifact" do
      expect(artifact_resolve.artifact).to be_a(Saml::Artifact)
    end
  end

  describe ".to_xml" do
    let(:artifact_resolve_xml) { File.read(File.join('spec','fixtures','artifact_resolve.xml')) }
    let(:artifact_resolve) { Saml::ArtifactResolve.parse(artifact_resolve_xml, :single => true) }
    let(:new_artifact_resolve_xml) { artifact_resolve.to_xml }
    let(:new_artifact_resolve) { Saml::ArtifactResolve.parse(new_artifact_resolve_xml) }

    it "should generate a parseable XML document" do
      expect(new_artifact_resolve).to be_a(Saml::ArtifactResolve)
    end
  end
end
