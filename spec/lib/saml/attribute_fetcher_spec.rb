require 'spec_helper'

class AttributeFetcherDummy
  include Saml::Base
  include Saml::AttributeFetcher

  has_many :attributes, Saml::Elements::Attribute
end

describe AttributeFetcherDummy do

  subject { described_class.new }

  let(:attribute_value_1) { build :attribute_value, content: 'value' }
  let(:attribute_value_2) { build :attribute_value, content: 'another value' }

  let(:attribute_1) { build :attribute, name: 'key', attribute_values: [ attribute_value_1 ] }
  let(:attribute_2) { build :attribute, name: 'key', attribute_values: [ attribute_value_1 ] }
  let(:attribute_3) { build :attribute, name: 'key_3', attribute_values: [ attribute_value_2 ] }

  before { subject.attributes = [ attribute_1, attribute_2, attribute_3 ] }

  describe '#fetch_attribute' do
    it 'returns the attribute value content' do
      expect(subject.fetch_attribute('key')).to eq 'value'
    end
  end

  describe '#fetch_attributes' do
    it 'returns the attributes' do
      expect(subject.fetch_attributes('key')).to match_array %w(value value)
    end
  end

  describe '#fetch_attribute_values' do
    it 'returns the attribute values' do
      expect(subject.fetch_attribute_values('key').map(&:content)).to match_array %w(value value)
    end
  end

  describe '#fetch_attribute_value' do
    it 'returns the attribute value' do
      expect(subject.fetch_attribute_value('key_3').content).to eq 'another value'
    end
  end

end
