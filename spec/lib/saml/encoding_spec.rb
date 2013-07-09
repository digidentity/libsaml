require 'spec_helper'

describe Saml::Encoding do
  describe ".encode_64" do
    it "encodes with base64" do
      Base64.decode64(described_class.encode_64("test")).should == "test"
    end
  end

  describe ".decode_64" do
    it "decodes with base64" do
      described_class.decode_64(Base64.encode64("test")).should == "test"
    end
  end

  describe ".encode_gzip" do
    it "encodes with gzip" do
      Zlib::Inflate.new(-Zlib::MAX_WBITS).inflate(described_class.encode_gzip("test")).should == "test"
    end
  end

  describe ".decode_gzip" do
    it "decodes with header" do
      described_class.decode_gzip(Zlib::Deflate.deflate("test", 9)).should == "test"
    end

    it "decodes without header" do
      described_class.decode_gzip(Zlib::Deflate.deflate("test", 9)[2..-5]).should == "test"
    end
  end
end