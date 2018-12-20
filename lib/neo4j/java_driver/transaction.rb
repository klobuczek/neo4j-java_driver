require 'neo4j/core/cypher_session/transactions'

module Neo4j
  module JavaDriver
    class Transaction < Neo4j::Core::CypherSession::Transactions::Base
      attr_reader :java_tx, :java_session

      def initialize(*args)
        begin
          super
          return unless root?
          @java_session = session.adaptor.driver.session(Neo4j::Driver::AccessMode::WRITE)
          @java_tx = @java_session.begin_transaction
        rescue Exception => e
          clean_transaction_registry
          @java_tx.close if @java_tx
          @java_session.close if @java_session
          raise e
        end

      end

      def commit
        return unless root?
        begin
          @java_tx.success
          @java_tx.close
        ensure
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

      private

      def clean_transaction_registry
        Neo4j::Transaction::TransactionsRegistry.transactions_by_session_id[session.object_id] = []
      end
    end
  end
end
