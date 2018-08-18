lib = File.expand_path('lib', __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'neo4j/java_driver/version'

Gem::Specification.new do |spec|
  spec.name = 'neo4j-java_driver'
  spec.version = Neo4j::JavaDriver::VERSION
  spec.authors = ['Heinrich Klobuczek']
  spec.email = ['heinrich@mail.com']

  spec.summary = 'neo4j-core adaptor based on neo4j java driver'
  spec.homepage = 'https://github.com/neo4jrb/neo4j-java_driver'
  spec.license = 'MIT'

  # Prevent pushing this gem to RubyGems.org. To allow pushes either set the 'allowed_push_host'
  # to allow pushing to a single host or delete this section to allow pushing to any host.
  if spec.respond_to?(:metadata)
    spec.metadata['allowed_push_host'] = "TODO: Set to 'http://mygemserver.com'"
  else
    raise 'RubyGems 2.0 or newer is required to protect against ' \
      'public gem pushes.'
  end

  spec.files = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end

  spec.files += Dir['lib/**/*.jar']

  spec.bindir = 'exe'
  spec.executables = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.platform = 'java'

  spec.requirements << 'jar org.neo4j.driver, neo4j-java-driver, 1.6.2'

  spec.add_runtime_dependency 'neo4j-core', '>= 9.0.0'

  spec.add_development_dependency 'bundler', '~> 1.16'
  spec.add_development_dependency 'dotenv'
  spec.add_development_dependency('dryspec')
  spec.add_development_dependency 'rake', '~> 10.0'
  spec.add_development_dependency 'rspec', '~> 3.0'
  spec.add_development_dependency('rspec-its')
end
