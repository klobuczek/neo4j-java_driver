# this is a generated file, to avoid over-writing it just delete this comment
begin
  require 'jar_dependencies'
rescue LoadError
  require 'org/neo4j/driver/neo4j-java-driver/1.6.1/neo4j-java-driver-1.6.1.jar'
end

require_jar 'org.neo4j.driver', 'neo4j-java-driver', '1.6.1' if defined? Jars