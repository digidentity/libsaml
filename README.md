[![Build status](https://travis-ci.org/digidentity/libsaml.png?branch=master)](https://travis-ci.org/digidentity/libsaml)
[![Coverage status](https://coveralls.io/repos/digidentity/libsaml/badge.png)](https://coveralls.io/r/digidentity/libsaml)
[![Code climate](https://codeclimate.com/github/digidentity/libsaml.png)](https://codeclimate.com/github/digidentity/libsaml)
[![Dependency status](https://gemnasium.com/digidentity/libsaml.png)](https://coveralls.io/r/digidentity/libsaml)

# libsaml

Libsaml is a Ruby gem to easily create SAML 2.0 messages. This gem was written because other SAML gems were missing functionality such as XML signing.

Libsaml's features include:

- Multiple bindings:
    - HTTP-Post
    - HTTP-Redirect
    - HTTP-Artifact
    - SOAP
- XML signing and verification
- Pluggable backend for providers (FileStore backend included)

Copyright [Digidentity B.V.](https://www.digidentity.eu/), released under the MIT license. This gem was written by [Benoist Claassen](https://github.com/benoist).

## Installation

Place in your Gemfile:

```ruby
gem 'libsaml', require: 'saml'
```

## Usage

Below follows how to configure the SAML gem in a service provider.

Store the private key in:
`config/ssl/key.pem`

Store the public key of the identity provider in:
`config/ssl/trust-federate.cert`

Add the Identity Provider web container configuration file to `config/metadata/service_provider.xml`.

This contains an encoded version of the public key, generate this in the ruby console by typing:

```ruby
require 'openssl'
require 'base64'

pem = File.open("config/ssl/trust-federate.cert").read
cert = OpenSSL::X509::Certificate.new(pem)
output = Base64.encode64(cert.to_der).gsub("\n", "")
```

Add the Service Provider configuration file to: `config/metadata/service_provider.xml`:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<md:EntityDescriptor ID="_052c51476c9560a429e1171e8c9528b96b69fb57" entityID="my:very:original:entityid" xmlns:ds="http://www.w3.org/2000/09/xmldsig#" xmlns:md="urn:oasis:names:tc:SAML:2.0:metadata">
  <md:SPSSODescriptor>
    <md:KeyDescriptor use="signing">
      <ds:KeyInfo>
        <ds:X509Data>
          <ds:X509Certificate>SAME_KEY_AS_GENERATED_IN_THE_CONSOLE_BEFORE</ds:X509Certificate>
        </ds:X509Data>
      </ds:KeyInfo>
    </md:KeyDescriptor>
    <md:AssertionConsumerService Binding="urn:oasis:names:tc:SAML:2.0:bindings:HTTP-Post" Location="http://localhost:3000/saml/receive_response" index="0" isDefault="true"/>
  </md:SPSSODescriptor>
</md:EntityDescriptor>
```

Set up an intializer in `config/initializers/saml_config.rb`:

```ruby
Saml.setup do |config|
  config.register_store :file, Saml::ProviderStores::File.new("config/metadata", "config/ssl/key.pem"), default: true
end
```

By default this will use a SamlProvider model that uses the filestore, if you want a database driven model comment out the `#provider_store` function in the initializer and make a model that defines `#find_by_entity_id`:

```ruby
class SamlProvider < ActiveRecord::Base
  include Saml::Provider

  def self.find_by_entity_id(entity_id)
    find_by entity_id: entity_id
  end
end
```


Now you can make a SAML controller in `app/controllers/saml_controller.rb`:

```ruby
class SamlController < ApplicationController
  extend Saml::Rails::ControllerHelper
  current_provider "entity_id"

  def request_authentication
    provider = Saml.provider("my:very:original:entityid")
    destination = provider.single_sign_on_service_url(Saml::ProtocolBindings::HTTP_POST)

    authn_request = Saml::AuthnRequest.new(:destination => destination)

    session[:authn_request_id] = auth_request._id

    @saml_attributes = Saml::Bindings::HTTPPost.create_form_attributes(authn_request)

    render text: @saml_attributes.to_yaml
  end

  def receive_response
    if params["SAMLart"]
      # provider should be of type Saml::Provider
      @response = Saml::Bindings::HTTPArtifact.resolve(request, provider.artifact_resolution_service_url)
    elsif params["SAMLResponse"]
      @response = Saml::Bindings::HTTPost.receive_message(request, :response)
    else
       # handle invalid request
    end

    if @response && @response.success?
      if session[:authn_request_id] == @response.in_response_to
        @response.assertion.fetch_attribute('any_attribute')
      else
        # handle unrecognized response
      end
      reset_session
    else
      # handle failure
    end
  end
end
```

Don't forget to define the routes in `config/routes.rb`:

```ruby
  get "/saml/request_authentication" => "saml#request_authentication"
  get "/saml/receive_response" => "saml#receive_response"
```

## Contributing

- Fork the project
- Contribute your changes. Please make sure your changes are properly documented and covered by tests.
- Send a pull request
