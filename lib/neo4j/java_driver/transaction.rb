require 'neo4j/core/cypher_session/transactions'

module Neo4j
  module JavaDriver
    class Transaction < Neo4j::Core::CypherSession::Transactions::Base
      attr_reader :java_tx, :java_session

      def initialize(*args)
        super
        return unless root?
        @java_session = session.adaptor.driver.session(org.neo4j.driver.v1.AccessMode::WRITE)
        @java_tx = @java_session.beginTransaction
      end

      def commit
        return unless root?
        begin
          @java_tx.success
        rescue Java::OrgNeo4jGraphdb::TransactionFailureException => e
          raise CypherError, e.message
        ensure
          @java_tx.close
          @java_session.close
        end
      end

      def delete
        root.java_tx.failure
        root.java_tx.close
        root.java_session.close
      end

      def started?
        true
      end

      def root_tx
        root.java_tx
      end
    end
  end
end
