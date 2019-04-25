require 'spec_helper'

describe Saml::ComplexTypes::StatusResponseType do
  let(:status_response_type) { FactoryBot.build(:status_response_type_dummy) }

  describe "Required fields" do
    [:_id, :version, :issue_instant, :in_response_to, :status].each do |field|
      it "should have the #{field} field" do
        status_response_type.should respond_to(field)
      end

      it "should check the presence of #{field}" do
        status_response_type.send("#{field}=", nil)
        status_response_type.should_not be_valid
      end
    end
  end

  describe "Optional fields" do
    [:destination, :issuer].each do |field|
      it "should have the #{field} field" do
        status_response_type.should respond_to(field)
      end

      it "should allow #{field} to blank" do
        status_response_type.send("#{field}=", nil)
        status_response_type.valid?
        status_response_type.errors.entries.should == []
        status_response_type.send("#{field}=", "")
        status_response_type.valid?
        status_response_type.errors.entries.should == []
      end
    end
  end

  describe "parse" do
    let(:status_response_type_xml) { File.read(File.join('spec','fixtures','logout_response.xml')) }
    let(:status_response_type) { Saml::LogoutResponse.parse(status_response_type_xml) }

    it "should parse the InResponseTo" do
      status_response_type.in_response_to.should == "_43faa9487db98daa757214c2d233d31a8ac043be"
    end

    it "should parse the Status" do
      status_response_type.status.should be_a(Saml::Elements::Status)
    end
  end

  describe 'success?' do
    let(:status_response_type_xml) { File.read(File.join('spec','fixtures','logout_response.xml')) }
    let(:status_response_type) { Saml::LogoutResponse.parse(status_response_type_xml) }

    it 'returns true if the status is SUCCESS' do
      status_response_type.success?.should be true
    end

    it 'returns false if the status is not SUCCESS' do
      status_response_type.status = Saml::Elements::Status.new(status_code: Saml::Elements::StatusCode.new(value: Saml::TopLevelCodes::REQUESTER))
      status_response_type.success?.should be false
    end
  end

  describe '#status_detail' do
    context 'when initialized with a status detail' do
      let(:status_response_type) { StatusResponseTypeDummy.new(status_detail: FactoryBot.build(:status_detail)) }

      it 'adds a status detail to the status' do
        expect(status_response_type.status.status_detail).to be_a(Saml::Elements::StatusDetail)
      end
    end

    context 'when initialized without a status detail' do
      let(:status_response_type) { StatusResponseTypeDummy.new(status_detail: nil) }

      it 'does NOT add a status detail to the status' do
        expect(status_response_type.status.status_detail).to be_blank
      end
    end
  end

  describe '#status_message' do
    context 'when initialized with a status message' do
      let(:status_response_type) { StatusResponseTypeDummy.new(status_message: 'status message') }

      it 'adds a status message to the status' do
        expect(status_response_type.status.status_message).to eq 'status message'
      end
    end

    context 'when initialized without a status message' do
      let(:status_response_type) { StatusResponseTypeDummy.new(status_message: nil) }

      it 'does NOT add a status message to the status' do
        expect(status_response_type.status.status_message).to be_blank
      end
    end
  end
end
