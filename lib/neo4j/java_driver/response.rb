require 'neo4j/core/cypher_session/responses'

module Neo4j
  module JavaDriver
    class Response < Neo4j::Core::CypherSession::Responses::Base
      attr_reader :results

      def initialize(responses, options = {})
        @wrap_level = options[:wrap_level] || Neo4j::Core::Config.wrapping_level

        @results = responses.map do |response|
          result_from_data(response.keys, response)
        end
      end

      def result_from_data(columns, entities_data)
        rows = entities_data.map do |entity_data|
          entity_data.values.map do |value|
            wrap_value(value)
          end
        end

        Neo4j::Core::CypherSession::Result.new(columns, rows)
      end

      private

      def wrap_node(node)
        properties = properties(node)
        wrap_by_level(properties) { ::Neo4j::Core::Node.new(node.id, node.labels, properties) }
      end

      def wrap_relationship(rel)
        properties = properties(rel)
        wrap_by_level(properties) do
          ::Neo4j::Core::Relationship.new(rel.id, rel.type, properties, rel.startNodeId, rel.endNodeId)
        end
      end

      def wrap_path(path)
        nodes = path.nodes
        relationships = path.relationships
        none_value = nodes.zip(relationships).flatten.compact.map(&method(:properties))
        wrap_by_level(none_value) do
          ::Neo4j::Core::Path.new(nodes.map(&method(:wrap_node)),
                                  relationships.map(&method(:wrap_relationship)),
                                  nil)
        end
      end

      def wrap_value(value)
        case value.type.name
        when 'NODE'
          wrap_node(value.asNode)
        when 'RELATIONSHIP'
          wrap_relationship(value.asRelationship)
        when 'PATH'
          wrap_path(value.asPath)
        when 'LIST OF ANY?'
          value.java_method(:asList, [org.neo4j.driver.v1.util.Function]).call(&method(:wrap_value)).to_a
        when 'MAP'
          value.asMap(->(x) { wrap_value(x) }, nil).to_hash.symbolize_keys
        else
          value.asObject
        end
      end

      def properties(container)
        container.asMap.to_hash
      end
    end
  end
end
