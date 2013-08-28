# Functionality for visiting networks.
require 'vase/bag'
require 'vase/visit_policy'

module Vase
  # Class responsible for visiting a network.
  class Visitor
    # Initialize a visitor starting from a node and having a policy.
    def initialize(node, policy)
      @policy = policy
      @bag = policy.new_bag(node)
      @visited_nodes = {}
    end

    # Visit a single node.
    # This responds appropriately to the following actions from the policy:
    # :step_into - visit the children;
    # :step_over - skip the children;
    # :stop - stop the visit.
    # These can be returned from either the #visit_node or #visit_edge policy.
    def visit_node(node_info, options = {}, &block)
      # add the node to the set of visited nodes
      @visited_nodes[node_info.node.origin] = node_info.node
      # process the node visit
      node_action = @policy.visit_node(node_info, options, &block)
      case node_action
      when :step_into
        # traverse the children edges
        node.edges.each do |edge|
          edge_action = @policy.visit_edge(edge, options, &block)
          case edge_action
          when :step_into
            # traverse the child node
            @bag.push(node_info.new_node_info(edge.ticket))
          when :step_over
            # don't include the child
            return
          when :stop
            # stop the iteration
            @bag.clear()
            return
          end
        end
      when :step_over
        # don't include the children edges
        return
      when :stop
        # stop the iteration
        @bag.clear()
        return
      end
    end

    # Visit all the nodes.
    def visit_all(options = {}, &block)
      until @bag.empty?
        node = @bag.pop()
        visit_node(node, options, &block)
      end
    end

    # Returns the node having a particular origin.
    def [](origin)
      @visited_nodes[origin]
    end

    # Returns all the visited nodes.
    def nodes
      @visited_nodes.values
    end
  end
end
