require 'spec_helper'
describe Saml::Artifact, "with hex encoded attributes" do

  let(:artifact) { Saml::Artifact.new }

  it "should have a type_code of 0x0004" do
    expect(artifact.type_code).to eq("\000\004")
  end

  it "should have a source_id of 20 bytes" do
    artifact.source_id.size == 20
  end

  it "should have a message_handle of 20 bytes" do
    artifact.message_handle.size == 20
  end

  it "should have a random message_handle" do
    expect(artifact.message_handle).not_to eq(Saml::Artifact.new.message_handle)
  end

  it "should have a total length of 44 bytes" do
    expect(Base64.decode64(artifact.to_s).size).to eq(44)
  end

  context "endpoint index" do
    let(:artifact_string) { "AAQAANo5o+5ea0sNMlW/75VgGJCv2AcJbY2VGuPiI9goxi7s45u3fXoHeDE=" }

    context "without any parameters" do
      it "should have the default endpoint index of 0x0000" do
        expect(artifact.endpoint_index).to eq("\000\000")
      end
    end

    context "with an artifact as a parameter" do
      let(:artifact) { Saml::Artifact.new(artifact_string) }

      it "should have the default endpoint index of 0x0000" do
        expect(artifact.endpoint_index).to eq("\000\000")
      end
    end

    context "with an endpoint index as a parameter" do
      context "when the endpoint index is a number" do
        let(:artifact) { Saml::Artifact.new(nil, 1) }

        it "packs the number and sets the endpoint index to 0x0001" do
          expect(artifact.endpoint_index).to eq("\000\001")
        end
      end

      context "when the endpoint index is not a number" do
        let(:artifact) { Saml::Artifact.new(nil, "\000\001") }

        it "sets the endpoint index to 0x0001" do
          expect(artifact.endpoint_index).to eq("\000\001")
        end
      end
    end

    context "with an artifact and an endpoint index as parameters" do
      let(:artifact) { Saml::Artifact.new(artifact_string, 1) }

      it "should have the default endpoint index of 0x0000" do
        expect(artifact.endpoint_index).to eq("\000\000")
      end
    end
  end

  describe "#parse" do
    let(:artifact_xml) { File.read(File.join('spec','fixtures','artifact_resolve.xml')) }
    let(:artifact) { Saml::Artifact.parse(artifact_xml, single: true) }

    it "should create an Artifact" do
      expect(artifact).to be_a(Saml::Artifact)
    end

    it "should parse the artifact" do
      expect(artifact.artifact).to eq("AAQAAMh48/1oXIM+sDo7Dh2qMp1HM4IF5DaRNmDj6RdUmllwn9jJHyEgIi8=")
    end
  end

  describe ".to_xml" do
    it "should create xml" do

      expect(artifact.to_xml).to eq("<?xml version=\"1.0\"?>\n<Artifact>#{artifact.to_s}</Artifact>\n")
    end
  end

end
