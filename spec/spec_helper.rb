require 'dotenv'
Dotenv.load

require 'neo4j/java_driver'
require 'dryspec/helpers'
require 'rspec/its'
require 'neo4j_spec_helpers'

RSpec.configure do |config|
  config.include Neo4jSpecHelpers
  config.extend DRYSpec::Helpers

  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = '.rspec_status'

  # Disable RSpec exposing methods globally on `Module` and `main`
  # config.disable_monkey_patching!

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end
end
