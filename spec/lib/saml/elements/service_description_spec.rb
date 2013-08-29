require "spec_helper"

describe Saml::Elements::ServiceDescription do

  let(:value)               { "Service Description" }
  let(:service_description) { described_class.new(:value => value) }

  describe ".to_xml" do
    it "should generate xml" do
      service_description.to_xml.should eq "<?xml version=\"1.0\"?>\n<md:ServiceDescription xmlns:md=\"urn:oasis:names:tc:SAML:2.0:metadata\">#{value}</md:ServiceDescription>\n"
    end
  end

end
