### 3.4.0
* Stop using old ruby Hash Rocket syntax
* Use FactoryBot gem instead of FactoryGirl
* Remove Nokogiri gem version limitations
* Only allow 'expect' RSpec syntax
* Travis CI: remove JRuby 9.1.5.0 and add Ruby 2.5.3 and 2.6.3

### 3.3.0
* Added support to verify all signatures in a SAML message by using the corresponding KeyName
* instead of the KeyName of the first signature it finds in a SAML message.

### 3.2.3
* Allow non-signed AuthnRequest for O365 ECP use-case, thanks @nov

### 3.2.2
* Add support for `NameIDPolicy` in `AuthnRequest`, thanks @pzgz

### 3.2.1
* Update dependencies as a fix for CWE-287

### 3.1.2
* `NameId#SPNameQualifier` and `AttributeValue#NameId` for Shibboleth support, thanks @nov

### 3.1.1
* Allow specifying NameFormat & FriendlyName at Saml::Assertion#add_attribute, thanks @nov

### 3.0.9
* Added `Scoping` element to an `AuthnRequest`

### 3.0.8
* Backward compatibility fix. (#147)

### 3.0.7
* Added signature config and response location

### 3.0.6
* Fix the encryption of an EncryptedID element with multiple recipients.

### 3.0.3
* Use lambda for validations

### 3.0.2
* Allow the AuthnInstant to be set

### 3.0.0
* require active support version >= 4.2

### 2.24.1
* The POST Binding now allows unsigned AuthnRequests if specifically configured in the EntityDescriptor
* add_attribute now allows extra attributes to be set via add_attribute("key", "value", type: "xsi:string")

### 2.23.1
* Added method to encrypt attributes

### 2.22.2
* Added the ext:OriginalIssuer and ext:LastModified attributes from the SAML V2.0 Attribute Extensions to the AttributeType.

### 2.22.1
* Added config option to include nested prefixlists by default.

### 2.22.0
* Added option to include nested prefixlists before signing.

### 2.21.3
* Added more possible `AuthnContextClassRef` values.

### 2.21.2
* Fixed bug when a destination url contains a query string https://github.com/digidentity/libsaml/pull/120

### 2.21.1
* Clear OpenSSL error queue if verification fails - https://bugs.ruby-lang.org/issues/7215

### 2.21.0
* increase xml mapper version

### 2.20.6
* added config options `generate_key_name` to disable automatic keyname generation
* improved the key info lookup for role descriptors

### 2.20.5
* Fixed Provider encrypted_key recursion bug

### 2.20.4
* Fixed `EncryptedID`, now only parses the correct encrypted keys.

### 2.20.3
* Added #ssl_private_key and #ssl_certificate to the config.

### 2.20.2
* Only convert the not_before and not_on_or_after to the XML schema format when there is a value.

### 2.20.1
* Added the option to set a custom `subject` in the assertion

### 2.19.10
* Added the InclusiveNamespaces #prefix_list to the config

### 2.19.9
* allow soap wsa headers to be given

### 2.19.4
* fix audience backwardscompatibility

### 2.19.3
* add “fail_silent” option to “#decrypt_encrypted_id”.

### 2.19.2
* allow empty attributes

### 2.19.1
* return canonicalised xml after verify

### 2.18.1
* added `SessionIndex` to `LogoutRequest`

### 2.18.0
* added `attribute_fetcher` to samlp extensions
* added `Saml::Element::Audience`

### 2.16.0
* Added ability to password protect key file.
* Added `find_by_source_id` to `Saml::ProviderStore::File`
* Added http ca file config

### 2.15.8
* added the option to set a `status_message` on a `Status` through the initializer of a `Response`.

### 2.15.7
* added the `request_unsupported?` helper method to `Response`.

### 2.15.6
* allow `LogoutRequest` to use `xml_value`

### 2.15.5
* add `not_on_or_after` on logout requests

### 2.15.4
* call `use_original` on a root object with the object that requires the original value

### 2.15.2
* call `use_parsed` on an object before calling to_xml on the element or parent to use the parsed value

### 2.15.1
* added libsaml file for easier require

### 2.15.0
* upgrade to xmlmapper

### 2.14.0
* fix issue when using the redirect binding as an IDP

### 2.13.1
* revert use original XML when using parsed objects
* revert Saml::XMLInjector

### 2.13.0
* enhancements
    * added `Saml::XmlInjector` to inject already signed assertions
    * use original XML when using parsed objects

### 2.12.2
* enhancements
    * changed metadata lookup, to allow looking up SP, IDP and AA specific information combined in one entity descriptor

### 2.12.1
* enhancements
    * an `AudienceRestriction` now has many `Audience` elements.

### 2.12.0
* enhancements
    * prevent multiple ```Assertion``` elements and it’s elements being added as associations to the root element when there are nested ```Assertion``` elements.

### 2.11.2
* enhancements
    * added the `fetch_attribute_value` helper method to `Assertion` and `AttributeStatement`.
    * added the `fetch_attribute_values` helper method to `Assertion` and `AttributeStatement`.

### 2.11.1
* enhancements
    * added the `unknown_principal?` helper method to `Response`.

### 2.10.7
* enhancements
    * added `AssertionIDRef` to the AdviceType.
    * an `Assertion` now has many `AttributeStatements` instead of just one.

### 2.10.6
* enhancements
    * added `AttributeAuthorithyDescriptor` as a descriptor for the Provider, which now returns a `Saml::ComplexTypes::RoleDescriptorType` instead of a `Saml::ComplexTypes::SSODescriptorType`

### 2.10.5
* enhancements
    * add a new ```SubjectConfirmation``` element as an Array when a ```Subject``` is initialized
    * a ```SubjectConfirmation``` element has only one ```SubjectConfirmationData``` element

### 2.10.4
* enhancements
    * added `attribute_service_url` to `Saml::Provider`

### 2.10.3
* enhancements
    * added an `Advice`` element and it’s ```AdviceType``` complex type
    * added `Advice`` element on an ```Assertion``` element
    * added `EncryptedID`` element on a ```Subject``` element
    * added validation on ```Subject``` element to validate if an identifier is present and only one is specified

### 2.10.2
* bug fix parsing encrypted assertions

### 2.10.1
* enhancements
    * added a ```StatusMessage``` element to the ```Status``` element.
    * a ```StatusDetail``` element (which is optional) will only be added to a ```Status``` element when it’s provided as an argument, thus not by default.

### 2.10.0
* enhancements
    * an ```AttributeValue``` element can have an ```EncryptedID``` element
    * added helper methods for encrypting a ```NameId``` element and encrypting/decrypting an ```EncryptedID``` element

### 2.9.0
* enhancements
    * removed the ```http://www.w3.org/2001/XMLSchema``` and ```http://www.w3.org/2001/XMLSchema-instance``` namespaces from the ```to_soap``` method.

### 2.8.1
* enhancements
    * changed the ```#attribute_value=``` method on ```ComplexTypes::AttributeValue``` so it will replace the existing attribute values, instead of appending to it

### 2.8.0
* enhancements
    * added ```AttributeValue``` element
    * added the possibility to have many ```AttributeValue``` elements on elements which include the ```ComplexTypes::AttributeType```
    * the ```#attribute_value``` method on ```ComplexTypes::AttributeType``` is now deprecated

### 2.7.0
* updated xmlenc dependency
* enhancements
    * added the possibility to use a ```KeyDescriptor``` in the ```Util::EncryptAssertion``` method, so we can set the ```key_name``` in the encrypted assertion.

### 2.6.9
* enhancements
    * added ```name_id_formats``` to the ```SSODescriptorType``` complex type.

### 2.6.8
* enhancements
    * added the option to set a custom endpoint index for an ```Artifact```.

### 2.6.7
* enhancements
    * fixed a parsing bug where an unsigned ```ArtifactResponse``` received the signature of its inner signed message.

### 2.6.5
* enhancements
    * added ```authn_request``` element on an ```ArtifactResponse``` so that both a ```Response``` as well as an ```AuthnRequest``` can be transferred.

### 2.6.4
* enhancements
    * added ```attribute_authority_descriptor``` element, which extends the ```RoleDescriptorType``` complex type, to an ```entity_descriptor``` element
    * added ```role_descriptor_type``` complex type

### 2.6.3
* enhancements
    * added ```status_detail``` element

### 2.6.2
* enhancements
    * added metadata publication info element

### 2.6.1
* enhancements
    * added ```fetch_attributes``` method to fetch multiple attributes with the same name from an assertion

### 2.6.0
* updated xmlenc dependency

### 2.5.1
* enhancements
    * allow metadata ```key_descriptor``` use to be omitted and be used as default

### 2.5.0
* enhancements
    * added backwards compatible ```has_many``` for ```authn_context_class_refs``` so the SP can request more than one context

### 2.4.1
* enhancements
    * use a hash for the file store
    * allow metadata to be added to the file store on the fly

### 2.3.2
* bug fix
    * fixed alias method error

### 2.3.1
* enhancements
    * started this changelog
    * Added a new url provider store use:
    ```Saml::ProviderStores::Url.find_by_metadata_location(metadata_location)``` or
    ```Saml::ProviderStores::Url.find_by_entity_id(metadata_location)``` # allow use through ```Saml.provider(entity_id)```
    * Added the entity id to the error message when ```Saml.provider``` cannot find ```entity id```
