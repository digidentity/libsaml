require 'spec_helper'

describe Saml::Elements::AuthnContext do
  let(:authn_context) { FactoryBot.build(:authn_context) }

  describe "Optional fields" do
    [:authn_context_class_ref, :authenticating_authorities].each do |field|
      it "should have the #{field} field" do
        expect(authn_context).to respond_to(field)
      end

      it "should allow #{field} to blank" do
        authn_context.send("#{field}=", nil)
        expect(authn_context).to be_valid
      end
    end
  end

  describe "parse" do
    let(:authn_context_xml) { File.read(File.join('spec', 'fixtures', 'artifact_response.xml')) }
    let(:authn_context) { Saml::Elements::AuthnContext.parse(authn_context_xml, single: true) }

    it "should parse the AuthnContext" do
      expect(authn_context).to be_a(Saml::Elements::AuthnContext)
    end

    it "should parse the authn_context_class_ref" do
      expect(authn_context.authn_context_class_ref).to eq("urn:oasis:names:tc:SAML:2.0:ac:classes:PasswordProtectedTransport")
    end
  end
end
