require "spec_helper"

describe Saml::Elements::Audience do

  let(:value) { 'Audience' }
  subject { described_class.new(value: value) }

  describe '.to_xml' do
    it "should generate xml" do
      subject.to_xml.should eq "<?xml version=\"1.0\"?>\n<Audience>Audience</Audience>\n"
    end
  end

end
