require "spec_helper"

describe Saml::Elements::ServiceName do

  let(:value)        { "Service Name" }
  let(:service_name) { described_class.new(:value => value) }

  describe ".to_xml" do
    it "should generate xml" do
      service_name.to_xml.should eq "<?xml version=\"1.0\"?>\n<md:ServiceName xmlns:md=\"urn:oasis:names:tc:SAML:2.0:metadata\">#{value}</md:ServiceName>\n"
    end
  end

end
