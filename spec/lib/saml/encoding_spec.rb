require 'spec_helper'

describe Saml::Encoding do
  describe ".encode_64" do
    it "encodes with base64" do
      expect(Base64.decode64(described_class.encode_64("test"))).to eq "test"
    end
  end

  describe ".decode_64" do
    it "decodes with base64" do
      expect(described_class.decode_64(Base64.encode64("test"))).to eq "test"
    end
  end

  describe ".encode_gzip" do
    it "encodes with gzip" do
      expect(Zlib::Inflate.new(-Zlib::MAX_WBITS).inflate(described_class.encode_gzip("test"))).to eq "test"
    end
  end

  describe ".decode_gzip" do
    it "decodes with header" do
      expect(described_class.decode_gzip(Zlib::Deflate.deflate("test", 9))).to eq "test"
    end

    it "decodes without header" do
      expect(described_class.decode_gzip(Zlib::Deflate.deflate("test", 9)[2..-5])).to eq "test"
    end
  end
end
