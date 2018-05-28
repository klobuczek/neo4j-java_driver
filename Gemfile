source 'https://rubygems.org'

git_source(:github) { |repo_name| "https://github.com/#{repo_name}" }

# Specify your gem's dependencies in neo4j-java_driver.gemspec
gemspec

branch = ENV['NEO4J_CORE_BRANCH'] || ENV['TRAVIS_PULL_REQUEST_BRANCH'] || ENV['TRAVIS_BRANCH']
slug = !ENV['TRAVIS_PULL_REQUEST_SLUG'].to_s.empty? ? ENV['TRAVIS_PULL_REQUEST_SLUG'] : ENV['TRAVIS_REPO_SLUG']
if branch
  command = "curl --head https://github.com/#{slug}-core/tree/#{branch} | head -1"
  result = `#{command}`
  if result =~ /200 OK/
    gem 'neo4j-core', github: "#{slug}-core", branch: branch
  else
    gem 'neo4j-core', github: 'neo4jrb/neo4j-core', branch: 'master'
  end
elsif ENV['USE_LOCAL_CORE']
  gem 'neo4j-core', path: '../neo4j-core'
else
  gem 'neo4j-core'
end
