require 'simplecov'
require 'coveralls'

SimpleCov.formatter = SimpleCov::Formatter::MultiFormatter.new([
  SimpleCov::Formatter::HTMLFormatter,
  Coveralls::SimpleCov::Formatter
])

SimpleCov.start 'rails' do
  add_filter 'lib/libsaml.rb'
  add_filter 'lib/saml/version.rb'
end

# This file is copied to spec/ when you run 'rails generate rspec:install'
require 'saml'
require 'rspec/core'
require 'rspec/collection_matchers'
require 'factories/all'

I18n.enforce_available_locales = false

# Requires supporting ruby files with custom matchers and macros, etc,
# in spec/support/ and its subdirectories.
Dir[File.join(File.dirname(__FILE__), "support/**/*.rb")].each {|f| require f}

RSpec.configure do |config|
  # ## Mock Framework
  #
  # If you prefer to use mocha, flexmock or RR, uncomment the appropriate line:
  #
  # config.mock_with :mocha
  # config.mock_with :flexmock
  # config.mock_with :rr

  config.expect_with :rspec do |c|
    c.syntax = [:should, :expect]
  end

  config.mock_with :rspec do |c|
    c.yield_receiver_to_any_instance_implementation_blocks = false
    c.syntax = [:should, :expect]
  end

  # If you're not using ActiveRecord, or you'd prefer not to run each of your
  # examples within a transaction, remove the following line or assign false
  # instead of true.

  # If true, the base class of anonymous controllers will be inferred
  # automatically. This will be the default behavior in future versions of
  # rspec-rails.

  # Run specs in random order to surface order dependencies. If you find an
  # order dependency and want to debug it, you can fix the order by providing
  # the seed, which is printed after each run.
  #     --seed 1234
  config.filter_run :focus
  config.run_all_when_everything_filtered = true
  config.order = 'random'
  config.include FactoryGirl::Syntax::Methods
  config.raise_errors_for_deprecations!
end
