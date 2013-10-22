Saml.setup do |config|
  config.register_store :file, Saml::ProviderStores::File.new("spec/fixtures/metadata", "spec/fixtures/key.pem"), default: true
end

RSpec.configure do |config|
  config.before :each do
    Saml.current_provider = Saml.provider('https://idp.example.com')
  end
end
