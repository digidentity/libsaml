[![Build status](https://app.travis-ci.com/digidentity/libsaml.svg?branch=master)](https://app.travis-ci.com/digidentity/libsaml)
[![Coverage status](https://coveralls.io/repos/digidentity/libsaml/badge.png)](https://coveralls.io/r/digidentity/libsaml)
[![Code climate](https://codeclimate.com/github/digidentity/libsaml.png)](https://codeclimate.com/github/digidentity/libsaml)

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

Add the Identity Provider configuration file that your IdP should provide as `config/metadata/service_provider.xml`. It should have `IDPSSODescriptor` in it.

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
  current_provider "<sp_entity_id>"

  def request_authentication
    provider = Saml.provider("<idp_enity_id>")
    destination = provider.single_sign_on_service_url(Saml::ProtocolBinding::HTTP_POST)

    authn_request = Saml::AuthnRequest.new(destination: destination)

    session[:authn_request_id] = authn_request._id

    @saml_attributes = Saml::Bindings::HTTPPost.create_form_attributes(authn_request)
  end

  def receive_response
    if params["SAMLart"]
      # provider should be of type Saml::Provider
      @response = Saml::Bindings::HTTPArtifact.resolve(request, provider.artifact_resolution_service_url)
    elsif params["SAMLResponse"]
      @response = Saml::Bindings::HTTPPost.receive_message(request, :response)
    else
       # handle invalid request
    end

    if @response && @response.success?
      if session[:authn_request_id] == @response.in_response_to
        @response.assertion.fetch_attribute('any_attribute')
      else
        # handle unrecognized response
      end
      reset_session # It's good practice to reset sessions after authenticating to mitigate session fixation attacks
    else
      # handle failure
    end
  end
end
```

Add `app/views/saml/request_authentication.html.erb` for the POST binding:

```erbruby
<!DOCTYPE html>
<html>
<body>
<form method="post" action="<%= @saml_attributes[:location] %>" id="SAMLRequestForm">
  <%= @saml_attributes[:variables].each do |key, value| %>
    <input type="hidden" name="<%= key %>" value="<%= value %>"/>
  <%= end %>
  <input id="SAMLSubmitButton" type="submit" value="Submit"/>
</form>
<script>
  document.getElementById('SAMLSubmitButton').style.visibility = "hidden";
  document.getElementById('SAMLRequestForm').submit();
</script>
</body>
</html>
```

Don't forget to define the routes in `config/routes.rb`:

```ruby
  get "/saml/request_authentication" => "saml#request_authentication"
  get "/saml/receive_response" => "saml#receive_response"
  post "/saml/receive_response" => "saml#receive_response"
```

## Using libsaml as an IDP

Writing a solid identity provider really requires a deeper knowledge of the SAML protocol, so it's recommended to read more on the SAML 2.0 Wiki http://en.wikipedia.org/wiki/SAML_2.0.
When you understand what it says, read these parts of the specification:
http://docs.oasis-open.org/security/saml/v2.0/saml-core-2.0-os.pdf
http://docs.oasis-open.org/security/saml/v2.0/saml-bindings-2.0-os.pdf

Below is an example of a very primitive IDP Saml Controller

```ruby
class SamlController < ActionController::Base
  extend Saml::Rails::ControllerHelper
  current_provider "<idp_entity_id>"

  def receive_authn_request
    authn_request = if request.get?
      Saml::Bindings::HTTPRedirect.receive_message(request, type: :authn_request)
    elsif request.post?
      Saml::Bindings::HTTPPost.receive_message(request, :authn_request)
    else
      return head :not_allowed
    end
    request_id = authn_request._id

    session[:saml_request] = {
      request_id:    request_id,
      relay_state:   params['RelayState'],
      authn_request: authn_request.to_xml
    }

    if authn_request.invalid?
      redirect_to send_response_path(request_id: request_id)
    else
      redirect_to sign_in_path(return_to: send_response_path(request_id: request_id))
    end
  end

  def send_response
    return head :not_found if session[:saml_request][:request_id] != params[:request_id]

    authn_request = Saml::AuthnRequest.parse(session[:saml_request][:authn_request], single: true)

    response = if authn_request.invalid?
      build_failure(Saml::TopLevelCodes::REQUESTER, Saml::SubStatusCodes::REQUEST_DENIED)
    elsif account_signed_in?
      build_success_response
    else
      build_failure(Saml::TopLevelCodes::RESPONDER, Saml::SubStatusCodes::NO_AUTHN_CONTEXT, 'cancelled')
    end

    if authn_request.protocol_binding == Saml::ProtocolBinding::HTTP_POST
      # render an auto submit form with hidden fields set in the attributes hash
      @attribute = Saml::Bindings::HTTPPost.create_form_attributes(response, relay_state: session[:saml_request][:relay_state])
    else
      # handle unsupported binding
    end
  end

  private

  def build_failure(status_value, sub_status_value, status_detail)
    Saml::Response.new(in_response_to:   session[:saml_request][:request_id],
                       status_value:     status_value,
                       sub_status_value: sub_status_value,
                       status_detail:    status_detail)
  end

  def build_success_response(authn_request)
    assertion = Saml::Assertion.new(
      name_id:                 current_account.username, # Return anything that you can link to an account
      name_id_format:          'urn:oasis:names:tc:SAML:2.0:nameid-format:persistent',
      authn_context_class_ref: Saml::ClassRefs::PASSWORD_PROTECTED,
      in_response_to:          authn_request._id,
      recipient:               authn_request.assertion_url,
      audience:                authn_request.issuer)

    # adding custom attributes
    assertion.add_attribute('name', 'value')

    Saml::Response.new(in_response_to: authn_request._id,
                       assertion:      assertion,
                       status_value:   Saml::TopLevelCodes::SUCCESS)
  end
end
```

## Caveats

- SAMLResponse and Assertions have to be signed as per the SAML security guidelines (Some IDP's don't do this by default and require special configuration)

## Contributing

- Fork the project
- Contribute your changes. Please make sure your changes are properly documented and covered by tests.
- Send a pull request
