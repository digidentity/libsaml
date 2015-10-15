require "spec_helper"

describe Saml::ComplexTypes::AttributeType do
  let(:attribute_type) { FactoryGirl.build(:attribute_type_dummy) }

  describe "Required fields" do
    [:name].each do |field|
      it "should have the #{field} field" do
        attribute_type.should respond_to(field)
      end

      it "should check the presence of #{field}" do
        attribute_type.send("#{field}=", nil)
        attribute_type.should_not be_valid
      end
    end
  end

  describe "Optional fields" do
    [:format, :friendly_name, :attribute_values].each do |field|
      it "should have the #{field} field" do
        attribute_type.should respond_to(field)
      end

      it "should allow #{field} to blank" do
        attribute_type.send("#{field}=", nil)
        attribute_type.errors.entries.should == [] #be_valid
        attribute_type.send("#{field}=", "")
        attribute_type.errors.entries.should == [] #be_valid
      end
    end
  end

  describe "#parse" do
    let(:attribute_type_xml) { File.read(File.join('spec','fixtures','attribute.xml')) }
    let(:attribute_type) { Saml::Elements::Attribute.parse(attribute_type_xml, :single => true) }

    it "should create an Attribute" do
      attribute_type.should be_a(Saml::Elements::Attribute)
    end

    it 'should parse all the AttributeValues' do
      expect(attribute_type.attribute_values.count).to eq 2
    end
  end

  describe '#attribute_value (DEPRECATED)' do
    let(:attribute_value_1) { FactoryGirl.build(:attribute_value, content: 'foo') }
    let(:attribute_value_2) { FactoryGirl.build(:attribute_value, content: 'bar') }
    let(:attribute_type)    { FactoryGirl.build(:attribute_type_dummy, attribute_values: [attribute_value_1, attribute_value_2]) }

    it 'returns the value of the first attribute value' do
      expect(attribute_type.attribute_value).to eq 'foo'
    end
  end

  describe '#attribute_value=' do
    context 'when the attribute value is passed as a String' do
      it 'creates a new AttributeValue element and sets the content' do
        attribute_type.attribute_value = 'foo'
        expect(attribute_type.attribute_values.first.content).to eq 'foo'
      end
    end

    context 'when the attribute value is passed as an AttributeValue element' do
      it 'adds the attribute value to the attribute values' do
        attribute_type.attribute_value = Saml::Elements::AttributeValue.new content: 'bar'
        expect(attribute_type.attribute_values.first.content).to eq 'bar'
      end
    end
  end
end
