source "http://rubygems.org"

# Declare your gem's dependencies in saml.gemspec.
# Bundler will treat runtime dependencies like base dependencies, and
# development dependencies will be added by default to the :development group.
gemspec

gem "xmlenc", github: "digidentity/xmlenc", ref: "2e9d8adabca954e70afe7344da951d3af1d8a7ab"

# jquery-rails is used by the dummy application
gem "jquery-rails"

group :test, :development do
  gem 'rspec-rails'
  gem 'guard-rspec'
  gem 'simplecov'
  gem 'factory_girl_rails'
  gem 'sqlite3'
end

# Declare any dependencies that are still in development here instead of in
# your gemspec. These might include edge Rails or gems from your path or
# Git. Remember to move these dependencies to your gemspec before releasing
# your gem to rubygems.org.

# To use debugger
# gem 'debugger'
