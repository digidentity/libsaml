require 'spec_helper'

describe Saml::Elements::AttributeValue do

  subject { FactoryGirl.build(:attribute_value) }

  describe 'optional fields' do
    [:type].each do |field|
      it "should respond to the '#{field}' field" do
        expect(subject).to respond_to(field)
      end
    end
  end

  describe '#parse' do
    let(:attribute_xml) { File.read(File.join('spec','fixtures','attribute.xml')) }
    let(:attribute_value) { Saml::Elements::AttributeValue.parse(attribute_xml, :single => true) }

    it 'should create a Attribute' do
      expect(attribute_value).to be_a Saml::Elements::AttributeValue
    end

    it 'should know its type' do
      expect(attribute_value.type).to eq 'xs:string'
    end
  end

end
