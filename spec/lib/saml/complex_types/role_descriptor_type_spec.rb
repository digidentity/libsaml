require 'spec_helper'

describe Saml::ComplexTypes::RoleDescriptorType do
  let(:role_descriptor) { FactoryGirl.build(:role_descriptor_type_dummy) }

  describe 'required fields' do
    [:protocol_support_enumeration].each do |field|
      it "should have the #{field} field" do
        role_descriptor.should respond_to(field)
      end

      it 'should check the presence of #{field}' do
        role_descriptor.send("#{field}=", nil)
        role_descriptor.should_not be_valid
      end
    end
  end

  describe 'optional fields' do
    [:_id, :valid_until, :cache_duration, :error_url, :key_descriptors].each do |field|
      it "should have the #{field} field" do
        role_descriptor.should respond_to(field)
      end

      it "should allow #{field} to blank" do
        role_descriptor.send("#{field}=", nil)
        role_descriptor.should be_valid
      end
    end

    describe '#cache_duration' do
      let(:xml) { File.read('spec/fixtures/provider_with_cache_duration.xml') }

      context 'casts the cache_duration to a String' do
        it 'sp_sso_descriptor' do
          Saml::Elements::SPSSODescriptor.parse(xml, single: true).cache_duration.should be_a String
        end

        it 'idp_sso_descriptor' do
          Saml::Elements::IDPSSODescriptor.parse(xml, single: true).cache_duration.should be_a String
        end

        it 'attribute_authority_descriptor' do
          Saml::Elements::AttributeAuthorityDescriptor.parse(xml, single: true).cache_duration.should be_a String
        end
      end
    end
  end

  describe '#find_key_descriptor' do
    let(:key_descriptor_1) { FactoryGirl.build :key_descriptor, use: 'encryption' }

    let(:key_descriptor_2) do
      key_descriptor                   = FactoryGirl.build :key_descriptor, use: 'signing'
      key_descriptor.key_info.key_name = 'key'
      key_descriptor
    end

    let(:key_descriptor_3) { FactoryGirl.build :key_descriptor }

    before do
      role_descriptor.key_descriptors = [key_descriptor_1, key_descriptor_2]
    end

    context 'when a key name is specified' do
      it 'finds the key descriptor by the specified key name and use' do
        role_descriptor.find_key_descriptor('key', 'signing').should be_a Saml::Elements::KeyDescriptor
      end
    end

    context 'when a key name is not specified' do
      it 'finds the key descriptor by use' do
        role_descriptor.find_key_descriptor(nil, 'encryption').should be_a Saml::Elements::KeyDescriptor
      end

      context 'when use is not specified' do
        before do
          role_descriptor.key_descriptors = [key_descriptor_1, key_descriptor_3]
        end

        it 'finds the default key descriptor' do
          role_descriptor.find_key_descriptor(nil, 'signing').should be_a Saml::Elements::KeyDescriptor
        end
      end
    end

    context "when the key descriptors did not set use or key name" do
      let(:key_descriptor) do
        key_descriptor = FactoryGirl.build :key_descriptor
        key_descriptor.key_info.key_name = nil
        key_descriptor
      end

      before do
        role_descriptor.key_descriptors = [key_descriptor]
      end

      it "returns the first key descriptor even if use and keyname are requested" do
        role_descriptor.find_key_descriptor('key', 'signing').should eq key_descriptor
      end
    end

    context "when the key descriptors did not set key name but the message contains it" do
      let(:key_descriptor) do
        key_descriptor = FactoryGirl.build :key_descriptor, use: 'signing'
        key_descriptor.key_info.key_name = nil
        key_descriptor
      end

      before do
        role_descriptor.key_descriptors = [key_descriptor]
      end

      it "returns the first key descriptor even if use and keyname are requested" do
        role_descriptor.find_key_descriptor('key', 'signing').should eq key_descriptor
      end
    end
  end
end
