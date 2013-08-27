# Functionality for traversing networks.
module Vase
  # Determines what to visit and how far to go.
  class VisitPolicy
    def goes_not_beyond(node_info)
      false
    end

    def stops_at(node_info)
      false
    end

    def goes_through(edge)
      true
    end

    def visit_node(node_info, options = {}, &block)
      if stops_at(node_info)
        :stop
      elsif goes_not_beyond(node_info)
        :step_over
      else
        :step_into
      end
    end

    def visit_edge(edge, options = {}, &block)
      if goes_through(edge)
        :step_into
      else
        :step_over
      end
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

  # Default visit policy, for which declarative edsl creation is provided.
  class FlexibleVisitPolicy < SingleTimeVisitPolicy
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
      @goes_through(edge)
    end
  end

  class VisitCheck
    def call(origin)
      true
    end

    def and(other)
      AndVisitCheck.new(self, other)
    end

    def or(other)
      OrVisitCheck.new(self, other)
    end

    def not
      NotVisitCheck.new(self)
    end
  end

  class LevelVisitCheck < VisitCheck
    def initialize(level)
      @level = level
    end

    def call(node_info)
      node_info.level == @level
    end
  end

  class NodeVisitCheck < VisitCheck
    def initialize(node)
      @node = node
    end

    def call(node_info)
      node_info.node == @node
    end
  end

  class MarkerVisitCheck < VisitCheck
    def initialize(markers)
      @markers = markers
    end

    def call(edge)
      @markers.include?(edge.marker)
    end
  end

  class TicketVisitCheck < VisitCheck
    def initialize(tickets)
      @tickets = tickets
    end

    def call(edge)
      @tickets.include?(edge.ticket)
    end
  end

  class UnaryVisitCheck < VisitCheck
    def initialize(check)
      @check = check
    end
  end

  class NotVisitCheck < UnaryVisitCheck
    def call(origin)
      not @check.call(origin)
    end
  end

  class BinaryVisitCheck < VisitCheck
    def initialize(check1, check2)
      @check1 = check1
      @check2 = check2
    end
  end

  class AndVisitCheck < BinaryVisitCheck
    def call(origin)
      @check1.call(origin) and @check2.call(origin)
    end
  end

  class OrVisitCheck < BinaryVisitCheck
    def call(origin)
      @check1.call(origin) or @check2.call(origin)
    end
  end

  def visit_policy(options)
    FlexibleVisitPolicy.new(options[:goes_not_beyond],
                            options[:stops_at],
                            options[:goes_through])
  end

  # Base class holding additional information for a node during traversion.
  class NodeInfo
    attr_reader :node, :parent_node, :ticket, :level

    def initialize(node, parent_node, ticket, level)
      @node = node
      @parent_node = parent_node
      @ticket = ticket
      @level = level
    end

    def new_node_info(ticket)
      NodeInfo.new(node[ticket], node, ticket, 1 + level)
    end
  end

  # Performs the actual traversion.
  class Traversor
    def initialize(bag, visit_policy)
      @bag = bag
      @visit_policy = visit_policy
    end

    # Traverses a single node.
    def traverse_node(node_info, options = {}, &block)
      node_action = @visit_policy.visit_node(node_info, options, &block)
      case node_action
      when :step_into
        # traverse the children edges
        node.edges.each do |edge|
          edge_action = @visit_policy.visit_edge(edge, options, &block)
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
  end

  # Traverse all the nodes.
  def traverse_all(options = {}, &block)
    until @bag.empty?
      node = @bag.pop()
      traverse_node(node, options, &block)
    end
  end
end
