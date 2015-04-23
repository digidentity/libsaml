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
