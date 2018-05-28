require 'neo4j/java_driver/adaptor'
require 'neo4j/core/shared_examples/adaptor'
require 'dryspec/helpers'

def port
  URI(ENV['NEO4J_BOLT_URL']).port
end

describe Neo4j::JavaDriver::Adaptor, bolt: true do
  let(:adaptor_class) { Neo4j::JavaDriver::Adaptor }
  let(:url) { ENV['NEO4J_BOLT_URL'] }

  # let(:adaptor) { adaptor_class.new(url, logger_level: Logger::DEBUG) }
  let(:adaptor) { adaptor_class.new(url) }

  after(:context) do
    Neo4j::JavaDriver::DriverRegistry.instance.close_all
  end

  subject { adaptor }

  describe '#initialize' do
    let_context(url: 'url') { subject_should_raise ArgumentError, /Invalid URL/ }
    let_context(url: :symbol) { subject_should_raise ArgumentError, /Invalid URL/ }
    let_context(url: 123) { subject_should_raise ArgumentError, /Invalid URL/ }

    let_context(url: "http://localhost:#{port}") { subject_should_raise ArgumentError, /Invalid URL/ }
    let_context(url: "http://foo:bar@localhost:#{port}") { subject_should_raise ArgumentError, /Invalid URL/ }
    let_context(url: "https://localhost:#{port}") { subject_should_raise ArgumentError, /Invalid URL/ }
    let_context(url: "https://foo:bar@localhost:#{port}") { subject_should_raise ArgumentError, /Invalid URL/ }

    let_context(url: 'bolt://foo@localhost:') { port == '7687' ? subject_should_not_raise : subject_should_raise }
    let_context(url: "bolt://:foo@localhost:#{port}") { subject_should_not_raise }

    let_context(url: "bolt://localhost:#{port}") { subject_should_not_raise }
    let_context(url: "bolt://foo:bar@localhost:#{port}") { subject_should_not_raise }
  end

  context 'connected adaptor' do
    before { adaptor.connect }

    it_behaves_like 'Neo4j::Core::CypherSession::Adaptor'
  end
end
