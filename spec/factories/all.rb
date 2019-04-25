require 'factory_bot'

class RequestAbstractTypeDummy
  include Saml::ComplexTypes::RequestAbstractType
end

class StatusResponseTypeDummy
  include Saml::ComplexTypes::StatusResponseType
end

class RoleDescriptorTypeDummy
  include Saml::ComplexTypes::RoleDescriptorType
end

class SsoDescriptorTypeDummy
  include Saml::ComplexTypes::SSODescriptorType
end

class AttributeTypeDummy
  include Saml::ComplexTypes::AttributeType
end

class LocalizedNameTypeDummy
  include Saml::ComplexTypes::LocalizedNameType
end

class SubjectQueryAbstractTypeDummy
  include Saml::ComplexTypes::SubjectQueryAbstractType
end

class AttributeQueryTypeDummy
  include Saml::ComplexTypes::AttributeQueryType
end

class AdviceTypeDummy
  include Saml::ComplexTypes::AdviceType
end

class StatementDummy
  include XmlMapper

  register_namespace 'xacml-saml', "urn:oasis:xacml:2.0:saml:assertion:schema:os"
  register_namespace 'xsi', Saml::XSI_NAMESPACE

  tag 'Statement'
  namespace 'saml'

  attribute :type, String, tag: 'xsi:type'

  element :authorization, String, tag: 'Authorization', namespace: :'xacml-saml'
end

FactoryBot.define do
  factory :request_abstract_type_dummy, :class => RequestAbstractTypeDummy do
    _id           { "_#{Time.now.to_i}" }
    version       { "2.0" }
    issue_instant { Time.now }
    issuer        { "http://sp.example.com" }
    destination   { "http://test.url/sso" }
  end

  factory :status_code, :class => Saml::Elements::StatusCode do
    value { Saml::TopLevelCodes::SUCCESS }
  end

  factory :status_detail, :class => Saml::Elements::StatusDetail do
    status_value { 'foo_status_value' }
  end

  factory :status, :class => Saml::Elements::Status do
    status_code   { FactoryBot.build(:status_code) }
    status_detail { FactoryBot.build(:status_detail) }
  end

  factory :status_response_type_dummy, :class => StatusResponseTypeDummy do
    _id             { "_#{Time.now.to_i}" }
    version         { "2.0" }
    issue_instant   { Time.now }
    in_response_to  { "_#{Time.now.to_i}" }
    status          { FactoryBot.build(:status) }
  end

  factory :role_descriptor_type_dummy, :class => RoleDescriptorTypeDummy do
  end

  factory :sso_descriptor_type_dummy, :class => SsoDescriptorTypeDummy do
    protocol_support_enumeration { Saml::ComplexTypes::RoleDescriptorType::PROTOCOL_SUPPORT_ENUMERATION }
  end

  factory :attribute_type_dummy, :class => AttributeTypeDummy do
  end

  factory :localized_name_type_dummy, :class => LocalizedNameTypeDummy do
  end

  factory :assertion, :class => Saml::Assertion do
    _id           { "_#{Time.now.to_i}" }
    version       { "2.0" }
    issue_instant { Time.now }
    issuer        { "valid_issuer" }
  end

  factory :encrypted_assertion, class: Saml::Elements::EncryptedAssertion do

  end

  factory :encrypted_id, class: Saml::Elements::EncryptedID do
  end

  factory :conditions, :class => Saml::Elements::Conditions do

  end

  factory :subject_confirmation_data, :class => Saml::Elements::SubjectConfirmationData do

  end

  factory :subject_confirmation, :class => Saml::Elements::SubjectConfirmation do

  end

  factory :subject, :class => Saml::Elements::Subject do

  end

  factory :audience, :class => Saml::Elements::Audience do

  end

  factory :audience_restriction, :class => Saml::Elements::AudienceRestriction do

  end

  factory :authn_context, :class => Saml::Elements::AuthnContext do

  end

  factory :authn_statement, :class => Saml::Elements::AuthnStatement do
    authn_instant { Time.now }
    authn_context { FactoryBot.build(:authn_context) }
  end

  factory :requested_attribute, :class => Saml::Elements::RequestedAttribute do

  end

  factory :attribute_consuming_service, :class => Saml::Elements::AttributeConsumingService do

  end

  factory :attribute, :class => Saml::Elements::Attribute do

  end

  factory :attribute_value, :class => Saml::Elements::AttributeValue do
  end

  factory :attribute_statement, :class => Saml::Elements::AttributeStatement do
    attributes { [ FactoryBot.build(:attribute) ] }
  end

  factory :subject_locality, :class => Saml::Elements::SubjectLocality do

  end

  factory :requested_authn_context, :class => Saml::Elements::RequestedAuthnContext do
    comparison              { 'minimum' }
    authn_context_class_ref { Saml::ClassRefs::PASSWORD_PROTECTED }
  end

  factory :authn_request, :class => Saml::AuthnRequest, :parent => :request_abstract_type_dummy do
    force_authn                       { false }
    assertion_consumer_service_index  { 0 }
    provider_name                     { "provider name" }
    requested_authn_context           { FactoryBot.build(:requested_authn_context) }
  end

  factory :response, :class => Saml::Response, :parent => :status_response_type_dummy do

  end

  factory :artifact_response, :class => Saml::ArtifactResponse, :parent => :status_response_type_dummy do

  end

  factory :artifact_resolve, :class => Saml::ArtifactResolve, :parent => :request_abstract_type_dummy do
    artifact { Saml::Artifact.new("AAQAAMh48/1oXIM+sDo7Dh2qMp1HM4IF5DaRNmDj6RdUmllwn9jJHyEgIi8=") }
  end

  factory :logout_request, :class => Saml::LogoutRequest, :parent => :request_abstract_type_dummy do
    name_id { "s00000000:12345678" }
  end

  factory :logout_response, :class => Saml::LogoutResponse, :parent => :status_response_type_dummy do
  end

  factory :entity_descriptor, :class => Saml::Elements::EntityDescriptor do
    entity_id { "http://idp.example.com/metadata" }
  end

  factory :entities_descriptor, :class => Saml::Elements::EntitiesDescriptor do
    entity_descriptors   { [FactoryBot.build(:entity_descriptor)] }
    entities_descriptors { ["entities_descriptor"] }
  end

  factory :key_descriptor, :class => Saml::Elements::KeyDescriptor do
    certificate { File.read("spec/fixtures/certificate.pem") }
  end

  factory :organization, :class => Saml::Elements::Organization do
  end

  factory :contact_person, :class => Saml::Elements::ContactPerson do
    contact_type      { Saml::Elements::ContactPerson::ContactTypes::TECHNICAL }
    telephone_numbers { ["0612345678"] }
    email_addresses   { ["technical@example.com"] }
  end

  factory :publication_info, :class => Saml::Elements::PublicationInfo do
    publisher         { "http://idp.example.com/metadata" }
    creation_instant  { Time.now }
  end

  factory :subject_query_abstract_type_dummy, :class => SubjectQueryAbstractTypeDummy do
    _id           { "_#{Time.now.to_i}" }
    version       { "2.0" }
    issue_instant { Time.now }
    subject       { FactoryBot.build(:subject) }
  end

  factory :attribute_query_type_dummy, :class => AttributeQueryTypeDummy do
    _id           { "_#{Time.now.to_i}" }
    version       { "2.0" }
    issue_instant { Time.now }
  end

  factory :advice_type_dummy, class: AdviceTypeDummy do
    assertions { [FactoryBot.build(:assertion)] }
  end

  factory :name_id, class: Saml::Elements::NameId do
    value { 'NameID' }
  end

  factory :session_index, class: Saml::Elements::SessionIndex do
    value { 'SessionIndex' }
  end

  factory :scoping, :class => Saml::Elements::Scoping do
  end

  factory :idp_list, :class => Saml::Elements::IdpList do
  end

  factory :idp_entry, :class => Saml::Elements::IdpEntry do
    provider_id { 'ProviderID' }
  end

end
