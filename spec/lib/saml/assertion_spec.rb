require 'spec_helper'

describe Saml::Assertion do
  let(:assertion) { FactoryGirl.build(:assertion) }

  describe "Required fields" do
    [:_id, :version, :issue_instant, :issuer].each do |field|
      it "should have the #{field} field" do
        assertion.should respond_to(field)
      end

      it "should check the presence of #{field}" do
        assertion.send("#{field}=", nil)
        assertion.should_not be_valid
      end
    end
  end

  describe "Optional fields" do
    [:subject, :conditions, :authn_statement, :attribute_statement].each do |field|
      it "should have the #{field} field" do
        assertion.should respond_to(field)
      end

      it "should allow #{field} to blank" do
        assertion.send("#{field}=", nil)
        assertion.should be_valid
        assertion.send("#{field}=", "")
        assertion.should be_valid
      end
    end
  end

  describe "parse" do
    let(:assertion_xml) { File.read(File.join('spec', 'fixtures', 'artifact_response.xml')) }
    let(:assertion) { Saml::Assertion.parse(assertion_xml, :single => true) }

    it "should parse the Assertion" do
      assertion.should be_a(Saml::Assertion)
    end

    it "should parse the id" do
      assertion._id.should == "_93af655219464fb403b34436cfb0c5cb1d9a5502"
    end

    it "should parse the version" do
      assertion.version.should == "2.0"
    end

    it "should parse the issuer" do
      assertion.issuer.should == "Provider"
    end

    it "should parse Subject" do
      assertion.subject.should be_a(Saml::Elements::Subject)
    end

    it "should parse Conditions" do
      assertion.conditions.should be_a(Saml::Elements::Conditions)
    end

    it "should parse AuthnStatement" do
      assertion.authn_statement.first.should be_a(Saml::Elements::AuthnStatement)
    end

    it "should parse AttributeStatement" do
      assertion.attribute_statement.should be_a(Saml::Elements::AttributeStatement)
    end

  end

  describe "provider" do
    it "returns the provider based on the issuer" do
      assertion = Saml::Assertion.new(issuer: "https://sp.example.com")
      assertion.provider.should == Saml.provider("https://sp.example.com")
    end
  end

  describe ".initialize" do
    it "should set the subject name id if name_id specified" do
      assertion = Saml::Assertion.new(:name_id => "subject")
      assertion.subject.name_id.should == "subject"
    end

    it "should set the audience if the audience is specified" do
      assertion = Saml::Assertion.new(:audience => "audience")
      assertion.conditions.audience_restriction.audience.should == "audience"
    end

    it "should set the address if the specified" do
      assertion = Saml::Assertion.new(:address => "127.0.0.1")
      assertion.authn_statement.subject_locality.address.should == "127.0.0.1"
    end

    it "should set the address if the specified" do
      assertion = Saml::Assertion.new(:authn_context_class_ref => "authn_context")
      assertion.authn_statement.authn_context.authn_context_class_ref.should == "authn_context"
    end
  end

  describe "IssueInstant" do
    it "should not be valid if the issue instant is too old" do
      assertion.issue_instant = Time.now - Saml::Config.max_issue_instant_offset.minutes
      assertion.should have(1).errors_on(:issue_instant)
    end
  end

  describe "Version" do
    it "should not be valid if the version is not allowed" do
      assertion.version = "invalid"
      assertion.should have(1).errors_on(:version)
    end
  end

  describe 'add_attribute' do
    it 'adds the attribute to the attribute statement' do
      assertion.add_attribute('key', 'value')
      assertion.attribute_statement.attribute.first.name.should == 'key'
      assertion.attribute_statement.attribute.first.attribute_value.should == 'value'
    end
  end

  describe 'fetch_attribute' do
    it 'returns the attribute from the attribute statement' do
      assertion.add_attribute('key', 'value')
      assertion.add_attribute('key2', 'value2')
      assertion.fetch_attribute('key2').should == 'value2'
    end

    it 'returns nil if attribute is not present' do
      assertion.fetch_attribute('not_present').should == nil
    end
  end
end
