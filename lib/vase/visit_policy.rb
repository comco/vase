# Policies determine how to perform a network visit.
require 'vase/bag'

module Vase
  # A node info representing the information needed per node during a
  # network visit.
  class NodeInfo
    attr_reader :node, :parent_node, :ticket, :level

    # Initialize a new node from a parent one.
    def initialize(node, parent_node, ticket, level)
      @node = node
      @parent_node = parent_node
      @ticket = ticket
      @level = level
    end

    def self.new_root(node)
      new(node, nil, nil, 0)
    end

    # Create a new node info for the child node, determined by a ticket.
    def new_node_info(ticket)
      NodeInfo.new(node[ticket], node, ticket, 1 + level)
    end
  end

  # Determines what to visit and how far to go.
  # The two methods #visit_node and #visit_edge can control the visit
  # by returning one of the following:
  # :step_into - visit the children;
  # :step_over - skip the children;
  # :stop - stop the visit.
  # A policy also acts as a factory for initializing particular bags
  # for a visitor.
  class VisitPolicy
    # Should the visit continue through the node with the given info.
    def goes_not_beyond(node_info)
      false
    end

    # Should the visit stop at the node with the given info.
    def stops_at(node_info)
      false
    end

    # Should the visit go through a given edge.
    def goes_through(edge)
      true
    end

    # Controls the visit of a node.
    def visit_node(node_info, options = {}, &block)
      if stops_at(node_info)
        :stop
      elsif goes_not_beyond(node_info)
        :step_over
      else
        :step_into
      end
    end

    # Controls the visit of an edge.
    def visit_edge(edge, options = {}, &block)
      if goes_through(edge)
        :step_into
      else
        :step_over
      end
    end

    # Controls the creation of a new bag for visit initialization.
    def new_bag(node)
      node_info = NodeInfo.new(node)
      BFS.new(node)
    end
  end

  # Policy that ensures each node is visited a single time.
  class SingleTimeVisitPolicy < VisitPolicy
    def initialize
      @visited = Set.new
    end

    def visit_node(node_info, options = {}, &block)
      @visited.add(node_info.node)
      super
    end

    def visit_edge(edge, options = {}, &block)
      if @visited_nodes.include? edge.target
        :step_over
      else
        super
      end
    end
  end

  # The default visit policy, supporting declarative creation through 
  # VisitChecks.
  class FlexibleVisitPolicy < SingleTimeVisitPolicy
    # The policy is initialized by visit checks.
    def initialize(goes_not_beyond, stops_at, goes_through)
      @goes_not_beyond = goes_not_beyond
      @stops_at = stops_at
      @goes_through = goes_through
    end

    def goes_not_beyond(node_info)
      @goes_not_beyond.call(node_info)
    end

    def stops_at(node_info)
      @stops_at.call(node_info)
    end

    def goes_through(edge)
      @goes_through.call(edge)
    end
  end
end
