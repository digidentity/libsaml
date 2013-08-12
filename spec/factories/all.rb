require 'factory_girl'
class RequestAbstractTypeDummy
  include Saml::ComplexTypes::RequestAbstractType
end

class StatusResponseTypeDummy
  include Saml::ComplexTypes::StatusResponseType
end

class SsoDescriptorTypeDummy
  include Saml::ComplexTypes::SSODescriptorType
end

FactoryGirl.define do
  factory :request_abstract_type_dummy, :class => RequestAbstractTypeDummy do
    _id "_#{Time.now.to_i}"
    version "2.0"
    issue_instant Time.now
    issuer "http://sp.example.com"
  end

  factory :status_code, :class => Saml::Elements::StatusCode do
    value Saml::TopLevelCodes::SUCCESS
  end

  factory :status, :class => Saml::Elements::Status do
    status_code FactoryGirl.build(:status_code)
  end

  factory :status_response_type_dummy, :class => StatusResponseTypeDummy do
    _id "_#{Time.now.to_i}"
    version "2.0"
    issue_instant Time.now
    in_response_to "_#{Time.now.to_i}"
    status FactoryGirl.build(:status)
  end

  factory :sso_descriptor_type_dummy, :class => SsoDescriptorTypeDummy do
    protocol_support_enumeration Saml::ComplexTypes::SSODescriptorType::PROTOCOL_SUPPORT_ENUMERATION
  end

  factory :assertion, :class => Saml::Assertion do
    _id "_#{Time.now.to_i}"
    version "2.0"
    issue_instant Time.now
    issuer "valid_issuer"
  end

  factory :conditions, :class => Saml::Elements::Conditions do

  end

  factory :subject_confirmation_data, :class => Saml::Elements::SubjectConfirmationData do

  end

  factory :subject_confirmation, :class => Saml::Elements::SubjectConfirmation do

  end

  factory :subject, :class => Saml::Elements::Subject do

  end

  factory :audience_restriction, :class => Saml::Elements::AudienceRestriction do

  end

  factory :authn_context, :class => Saml::Elements::AuthnContext do

  end

  factory :authn_statement, :class => Saml::Elements::AuthnStatement do
    authn_instant Time.now
    authn_context FactoryGirl.build(:authn_context)
  end


  factory :attribute, :class => Saml::Elements::Attribute do

  end

  factory :attribute_statement, :class => Saml::Elements::AttributeStatement do
    attribute FactoryGirl.build(:attribute)
  end

  factory :subject_locality, :class => Saml::Elements::SubjectLocality do

  end

  factory :requested_authn_context, :class => Saml::Elements::RequestedAuthnContext do
    comparison 'minimum'
    authn_context_class_ref Saml::ClassRefs::PASSWORD_PROTECTED
  end

  factory :authn_request, :class => Saml::AuthnRequest, :parent => :request_abstract_type_dummy do
    force_authn false
    assertion_consumer_service_index 0
    provider_name "provider name"
    requested_authn_context FactoryGirl.build(:requested_authn_context)
  end

  factory :response, :class => Saml::Response, :parent => :status_response_type_dummy do

  end

  factory :artifact_response, :class => Saml::ArtifactResponse, :parent => :status_response_type_dummy do

  end

  factory :artifact_resolve, :class => Saml::ArtifactResolve, :parent => :request_abstract_type_dummy do
    artifact Saml::Artifact.new("AAQAAMh48/1oXIM+sDo7Dh2qMp1HM4IF5DaRNmDj6RdUmllwn9jJHyEgIi8=")
  end

  factory :logout_request, :class => Saml::LogoutRequest, :parent => :request_abstract_type_dummy do
    name_id "s00000000:12345678"
  end

  factory :entity_descriptor, :class => Saml::Elements::EntityDescriptor do
    entity_id "http://idp.example.com/metadata"
  end

  factory :entities_descriptor, :class => Saml::Elements::EntitiesDescriptor do
    entity_descriptors [ FactoryGirl.build(:entity_descriptor) ]
    entities_descriptors [ "entities_descriptor" ]
  end

  factory :key_descriptor, :class => Saml::Elements::KeyDescriptor do
    certificate File.read("spec/fixtures/certificate.cer")
  end

  factory :organization, :class => Saml::Elements::Organization do
  end

  factory :contact_person, :class => Saml::Elements::ContactPerson do
    contact_type Saml::Elements::ContactPerson::ContactTypes::TECHNICAL
    telephone_numbers ["0612345678"]
    email_addresses ["technical@example.com"]
  end
end

