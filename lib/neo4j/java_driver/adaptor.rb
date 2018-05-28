require 'neo4j/core/cypher_session/adaptors'
require 'neo4j/core/cypher_session/adaptors/has_uri'
require 'neo4j/core/cypher_session/adaptors/schema'
require 'singleton'
require 'jruby/synchronized'

module Neo4j
  module JavaDriver
    # The registry is necessary due to the specs constantly creating new CypherSessions.
    # Closing a driver is costly. Not closing it prevents the process from termination.
    # The registry allow reusage of drivers which are thread safe and conveniently closing them in one call.
    class DriverRegistry < Hash
      include Singleton
      include JRuby::Synchronized

      at_exit do
        instance.close_all
      end

      def driver_for(url)
        self[url] ||= Java::OrgNeo4jDriverV1::GraphDatabase.driver(url)
      end

      def close(driver)
        delete(key(driver))
        driver.close
      end

      def close_all
        values.each(&:close)
        clear
      end
    end

    class Adaptor < Neo4j::Core::CypherSession::Adaptors::Base
      include Neo4j::Core::CypherSession::Adaptors::Schema
      include Neo4j::Core::CypherSession::Adaptors::HasUri
      default_url('bolt://neo4:neo4j@localhost:7687')
      validate_uri do |uri|
        uri.scheme == 'bolt'
      end

      attr_reader :driver

      def initialize(url, options = {})
        self.url = url
        @driver = DriverRegistry.instance.driver_for(url)
        @options = options
      end

      def connect; end

      def close
        DriverRegistry.instance.close(@driver)
      end

      def connected?
        @driver
      end

      def query_set(transaction, queries, options = {})
        setup_queries!(queries, transaction, skip_instrumentation: options[:skip_instrumentation])

        responses = queries.map do |query|
          transaction.root_tx.run(query.cypher, deep_stringify_keys(query.parameters))
        end
        wrap_level = options[:wrap_level] || @options[:wrap_level]
        Response.new(responses, wrap_level: wrap_level).results
      rescue Java::OrgNeo4jDriverV1Exceptions::Neo4jException => e
        raise Neo4j::Core::CypherSession::CypherError.new_from(e.code, e.message) # , e.stack_track.to_a
      end

      # def transaction(_session, &block)
      #   session = driver.session(org.neo4j.driver.v1.AccessMode::WRITE)
      #   session.writeTransaction(&block)
      # ensure
      #   session.close
      # end

      def self.transaction_class
        Transaction
      end

      instrument(:request, 'neo4j.core.bolt.request', %w[adaptor body]) do |_, start, finish, _id, payload|
        ms = (finish - start) * 1000
        adaptor = payload[:adaptor]

        type = nil # adaptor.ssl? ? '+TLS' : ' UNSECURE'
        " #{ANSI::BLUE}BOLT#{type}:#{ANSI::CLEAR} #{ANSI::YELLOW}#{ms.round}ms#{ANSI::CLEAR} #{adaptor.url_without_password}"
      end

      private

      def deep_stringify_keys(hash)
        hash.is_a?(Hash) ? hash.map { |key, value| [key.to_s, deep_stringify_keys(value)] }.to_h : hash
      end
    end
  end
end
