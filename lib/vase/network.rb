# Vase networks functionality.
# A network is an interconnected graph consisting of nodes, connected with
# edges. Each node has the ability to traverse its edges, and to select an
# edge based on a given ticket, if such an edge exists. Each edge has a
# source, a target, a marker and a ticket, which uniquely determines the
# edge on the source.
module Vase
  # Base class for representing nodes in a network.
  class Node
    attr_reader :origin

    def initialize(origin)
      @origin = origin
    end

    def edge(ticket)
      edges.find do |edge|
        edge.ticket == ticket
      end
    end

    def [](ticket)
      edge(ticket).target
    end
  end

  # Base class for representing edges in a network.
  class Edge
    attr_reader :source, :target, :marker, :ticket

    def initialize(source, target, marker, ticket)
      @source = source
      @target = target
      @marker = marker
      @ticket = ticket
    end

    # Edges have value-type-like equality syntax.
    def state
      [@source, @target, @marker, @ticket]
    end

    def hash
      state.hash
    end

    def ==(other)
      other.class == self.class && other.state == state
    end

    alias_method :eql?, :==
  end
end
