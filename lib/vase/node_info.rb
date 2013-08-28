# Functionality related with the additional information for nodes during a
# network visit.
module Vase
  # A node info representing the information needed per node during a
  # network visit.
  class NodeInfo
    attr_reader :node, :parent_node, :ticket, :level

    def initialize(node, parent_node, ticket, level)
      @node = node
      @parent_node = parent_node
      @ticket = ticket
      @level = level
    end

    # Create a new node info for the child node, determined by a ticket.
    def new_node_info(ticket)
      NodeInfo.new(node[ticket], node, ticket, 1 + level)
    end
  end
end
