### 2.4.1 (unreleased)
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
    Saml::ProviderStores::Url.find_by_metadata_location(metadata_location) or
    Saml::ProviderStores::Url.find_by_entity_id(metadata_location) # allow use through Saml.provider(entity_id)
  * Added the entity id to the error message when Saml.provider cannot find entity id
