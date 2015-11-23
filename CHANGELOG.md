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
