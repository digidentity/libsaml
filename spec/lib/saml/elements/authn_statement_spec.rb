require 'spec_helper'

describe Saml::Elements::AuthnStatement do
  let(:authn_statement) { FactoryBot.build(:authn_statement) }

  describe "Required fields" do
    [:authn_instant, :authn_context].each do |field|
      it "should have the #{field} field" do
        authn_statement.should respond_to(field)
      end

      it "should check the presence of #{field}" do
        authn_statement.send("#{field}=", nil)
        authn_statement.should_not be_valid
      end
    end
  end

  describe "Optional fields" do
    [:subject_locality, :session_index].each do |field|
      it "should have the #{field} field" do
        authn_statement.should respond_to(field)
      end

      it "should allow #{field} to blank" do
        authn_statement.send("#{field}=", nil)
        authn_statement.should be_valid
        authn_statement.send("#{field}=", "")
        authn_statement.should be_valid
      end
    end
  end

  describe "parse" do
    let(:authn_statement_xml) { File.read(File.join('spec', 'fixtures', 'artifact_response.xml')) }
    let(:authn_statement) { Saml::Elements::AuthnStatement.parse(authn_statement_xml, :single => true) }

    it "should parse the AuthnStatement" do
      authn_statement.should be_a(Saml::Elements::AuthnStatement)
    end

    it "should parse the SubjectLocality" do
      authn_statement.subject_locality.should be_a(Saml::Elements::SubjectLocality)
    end

    it "should parse the AuthnContext" do
      authn_statement.authn_context.should be_a(Saml::Elements::AuthnContext)
    end

    it "should parse the authn_instant" do
      authn_statement.authn_instant.should == Time.parse("2011-08-31T08:51:05Z")
    end

    it "should parse the session index" do
      authn_statement.session_index.should == "_93af655219464fb403b34436cfb0c5cb1d9a5502"
    end
  end

  describe "initialize" do
    it "should set the subject locality" do
      authn_statement = Saml::Elements::AuthnStatement.new(:address => "127.0.0.1")
      authn_statement.subject_locality.address.should == "127.0.0.1"
    end

    it "should set the authn_context" do
      authn_statement = Saml::Elements::AuthnStatement.new(:authn_context_class_ref => "urn:oasis:names:tc:SAML:2.0:ac:classes:PasswordProtectedTransport")
      authn_statement.authn_context.authn_context_class_ref.should == "urn:oasis:names:tc:SAML:2.0:ac:classes:PasswordProtectedTransport"
    end
  end
end
