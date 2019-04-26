require 'spec_helper'

describe Saml::ComplexTypes::RoleDescriptorType do
  let(:role_descriptor) { FactoryBot.build(:role_descriptor_type_dummy) }

  describe 'required fields' do
    [:protocol_support_enumeration].each do |field|
      it "should have the #{field} field" do
        expect(role_descriptor).to respond_to(field)
      end

      it 'should check the presence of #{field}' do
        role_descriptor.send("#{field}=", nil)
        expect(role_descriptor).not_to be_valid
      end
    end
  end

  describe 'optional fields' do
    [:_id, :valid_until, :cache_duration, :error_url, :key_descriptors].each do |field|
      it "should have the #{field} field" do
        expect(role_descriptor).to respond_to(field)
      end

      it "should allow #{field} to blank" do
        role_descriptor.send("#{field}=", nil)
        expect(role_descriptor).to be_valid
      end
    end

    describe '#cache_duration' do
      let(:xml) { File.read('spec/fixtures/provider_with_cache_duration.xml') }

      context 'casts the cache_duration to a String' do
        it 'sp_sso_descriptor' do
          expect(Saml::Elements::SPSSODescriptor.parse(xml, single: true).cache_duration).to be_a String
        end

        it 'idp_sso_descriptor' do
          expect(Saml::Elements::IDPSSODescriptor.parse(xml, single: true).cache_duration).to be_a String
        end

        it 'attribute_authority_descriptor' do
          expect(Saml::Elements::AttributeAuthorityDescriptor.parse(xml, single: true).cache_duration).to be_a String
        end
      end
    end
  end

  describe '#find_key_descriptor' do
    let(:key_descriptor_1) { FactoryBot.build :key_descriptor, use: 'encryption' }

    let(:key_descriptor_2) do
      key_descriptor                   = FactoryBot.build :key_descriptor, use: 'signing'
      key_descriptor.key_info.key_name = 'key'
      key_descriptor
    end

    let(:key_descriptor_3) { FactoryBot.build :key_descriptor }

    before do
      role_descriptor.key_descriptors = [key_descriptor_1, key_descriptor_2]
    end

    context 'when a key name is specified' do
      it 'finds the key descriptor by the specified key name and use' do
        expect(role_descriptor.find_key_descriptor('key', 'signing')).to be_a Saml::Elements::KeyDescriptor
      end
    end

    context 'when a key name is not specified' do
      it 'finds the key descriptor by use' do
        expect(role_descriptor.find_key_descriptor(nil, 'encryption')).to be_a Saml::Elements::KeyDescriptor
      end

      context 'when use is not specified' do
        before do
          role_descriptor.key_descriptors = [key_descriptor_1, key_descriptor_3]
        end

        it 'finds the default key descriptor' do
          expect(role_descriptor.find_key_descriptor(nil, 'signing')).to be_a Saml::Elements::KeyDescriptor
        end
      end
    end

    context "when the key descriptors did not set use or key name" do
      let(:key_descriptor) do
        key_descriptor = FactoryBot.build :key_descriptor
        key_descriptor.key_info.key_name = nil
        key_descriptor
      end

      before do
        role_descriptor.key_descriptors = [key_descriptor]
      end

      it "returns the first key descriptor even if use and keyname are requested" do
        expect(role_descriptor.find_key_descriptor('key', 'signing')).to eq key_descriptor
      end
    end

    context "when the key descriptors did not set key name but the message contains it" do
      let(:key_descriptor) do
        key_descriptor = FactoryBot.build :key_descriptor, use: 'signing'
        key_descriptor.key_info.key_name = nil
        key_descriptor
      end

      before do
        role_descriptor.key_descriptors = [key_descriptor]
      end

      it "returns the first key descriptor even if use and keyname are requested" do
        expect(role_descriptor.find_key_descriptor('key', 'signing')).to eq key_descriptor
      end
    end
  end

  describe '#find_key_descriptors_by_use' do
    let(:key_descriptor_1) { FactoryBot.build :key_descriptor }
    let(:key_descriptor_2) { FactoryBot.build :key_descriptor, use: 'signing' }
    let(:key_descriptor_3) { FactoryBot.build :key_descriptor, use: 'encryption' }
    let(:key_descriptor_4) do
      key_descriptor                   = FactoryBot.build :key_descriptor, use: 'encryption'
      key_descriptor.key_info.key_name = 'key'
      key_descriptor
    end

    before { role_descriptor.key_descriptors = [key_descriptor_1, key_descriptor_2, key_descriptor_3, key_descriptor_4] }

    context 'when "use" is specified' do
      let(:key_descriptors) { role_descriptor.find_key_descriptors_by_use('encryption') }

      it 'returns all key descriptors with the specified use' do
        aggregate_failures do
          expect(key_descriptors.count).to eq 2
          expect(key_descriptors.first).to eq key_descriptor_3
          expect(key_descriptors.second).to eq key_descriptor_4
        end
      end
    end

    context 'when NO "use" is specified' do
      let(:key_descriptors) { role_descriptor.find_key_descriptors_by_use(nil) }

      it 'returns key descriptors without use specified' do
        aggregate_failures do
          expect(key_descriptors.count).to eq 1
          expect(key_descriptors.first).to eq key_descriptor_1
        end
      end
    end
  end

end
