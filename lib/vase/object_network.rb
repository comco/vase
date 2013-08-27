# Provides the means to threat objects and structures in memory as networks.
require 'vase/network'

module Vase
  # Represents a network of objects. Objects are visited lazily.
  class ObjectNetwork
    def initialize
      @nodes = Hash.new
    end

    # Returns a node for the origin.
    def node(origin)
      @nodes[origin] = new_node(origin) unless @nodes.has_key? origin
      @nodes[origin]
    end

    # Creates a new node.
    def new_node(origin)
      case origin
      when Array
        ArrayNode.new(origin, self)
      when Hash
        HashNode.new(origin, self)
      when String, Integer, nil
        SimpleNode.new(origin, self)
      else
        StructNode.new(origin, self)
      end
    end

    # Returns all the nodes of this object network.
    def nodes
      @nodes.values
    end

    # Returns a node for an origin. 
    def [](origin)
      @nodes[origin]
    end
  end

  # Base class for object nodes.
  class ObjectNode < Node
    attr_reader :network

    def initialize(origin, network)
      super(origin)
      @network = network
    end
  end

  # Network node for simple types.
  class SimpleNode < ObjectNode
    def edges
      []
    end
  end

  # Network node for arrays.
  class ArrayNode < ObjectNode
    def edges
      origin.map.with_index do |element, index|
        Edge.new(self, network.node(element), :array_edge, index)
      end
    end
  end

  # Network node for hashes.
  class HashNode < ObjectNode
    def edges
      origin.map do |key, value|
        Edge.new(self, network.node(value), :hash_edge, key)
      end
    end
  end

  # Network node for structs.
  class StructNode < ObjectNode
    def edges
      fields = origin.instance_variables
      fields.map do |field|
        value = origin.instance_variable_get(field)
        Edge.new(self, network.node(value), :struct_edge, field)
      end
    end
  end
end
