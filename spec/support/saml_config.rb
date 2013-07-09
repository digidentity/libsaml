Saml.setup do |config|
  config.entity_id = "https://idp.example.com"
  config.provider_store = Saml::ProviderStores::File.new("spec/fixtures/metadata", "spec/fixtures/key.pem")
end
