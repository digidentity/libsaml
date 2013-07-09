require 'spec_helper'
describe Saml::Artifact, "with hex encoded attributes" do

  let(:artifact) { Saml::Artifact.new }

  it "should have a type_code of 0x0004" do
    artifact.type_code.should == "\000\004"
  end

  it "should have an endpoint_index of 0x000" do
    artifact.endpoint_index == "\000\000"
  end

  it "should have a source_id of 20 bytes" do
    artifact.source_id.size == 20
  end

  it "should have a message_handle of 20 bytes" do
    artifact.message_handle.size == 20
  end

  it "should have a random message_handle" do
    artifact.message_handle.should_not == Saml::Artifact.new.message_handle
  end

  it "should have a total length of 44 bytes" do
    Base64.decode64(artifact.to_s).size.should == 44
  end

  describe "#parse" do
    let(:artifact_xml) { File.read(File.join('spec','fixtures','artifact_resolve.xml')) }
    let(:artifact) { Saml::Artifact.parse(artifact_xml, :single => true) }

    it "should create an Artifact" do
      artifact.should be_a(Saml::Artifact)
    end

    it "should parse the artifact" do
      artifact.artifact.should == "AAQAAMh48/1oXIM+sDo7Dh2qMp1HM4IF5DaRNmDj6RdUmllwn9jJHyEgIi8="
    end
  end

  describe ".to_xml" do
    it "should create xml" do

      artifact.to_xml.should == "<?xml version=\"1.0\"?>\n<Artifact>#{artifact.to_s}</Artifact>\n"
    end
  end

end
