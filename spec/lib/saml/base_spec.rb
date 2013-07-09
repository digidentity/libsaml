require 'spec_helper'

class BaseDummy
  include Saml::Base

  tag 'tag'
end

describe BaseDummy do
  describe "parse override" do
    it "sets the from_xml flag" do
      BaseDummy.parse("<tag></tag>", single: true).from_xml?.should be_true
    end

    it "raises an error if the message cannot be parsed" do
      expect {
        BaseDummy.parse("invalid")
      }.to raise_error(Saml::Errors::UnparseableMessage)
    end

    it "raises an error if the message is nil" do
      expect {
        BaseDummy.parse(nil)
      }.to raise_error(Saml::Errors::UnparseableMessage)
    end
  end
end
