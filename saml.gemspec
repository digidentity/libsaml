$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "saml/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "libsaml"
  s.version     = Saml::VERSION
  s.authors     = ["Benoist Claassen"]
  s.email       = ["bclaassen@digidentity.eu"]
  s.homepage    = "https://www.digidentity.eu"
  s.license     = "MIT"
  s.summary     = "A gem to easily create SAML 2.0 messages."
  s.description = "Libsaml makes the creation of SAML 2.0 messages easy. The object structure is modeled after the SAML Core 2.0 specification from OASIS. Supported bindings are HTTP-Post, HTTP-Redirect, HTTP-Artifact and SOAP. Features include XML signing, XML verification and a pluggable backend for providers (FileStore backend included)."

  s.files = Dir["{lib}/**/*"] + ["MIT-LICENSE", "Rakefile", "README.md"]

  s.add_dependency "activesupport", ">= 4.2"
  s.add_dependency "activemodel", ">= 4.2"
  s.add_dependency "xmlmapper", '~> 0.7.2'
  s.add_dependency 'nokogiri', '~> 1.6', '>= 1.6.8'
  s.add_dependency "xmldsig", '>= 0.5.1', '< 0.7.0'
  s.add_dependency "xmlenc", '~> 0.6.2'

  s.add_development_dependency "coveralls", "~> 0.7"
end
