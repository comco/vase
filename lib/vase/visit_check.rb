# Different checks, handy during network visit.
require 'vase/visit_policy'

module Vase
  # Base class for all visit checks.
  class VisitCheck
    # Combine checks with 'and'.
    def and(other)
      AndOpVisitCheck.new(self, other)
    end

    # Combine checks with 'or'.
    def or(other)
      OrOpVisitCheck.new(self, other)
    end

    # Return the inverse of this check.
    def not
      NotOpVisitCheck.new(self)
    end
  end

  # Checks for a level of a node during network visit.
  class LevelVisitCheck < VisitCheck
    def initialize(levels)
      @levels = levels
    end

    def call(node_info)
      @levels.include?(node_info.level)
    end
  end

  def level(*levels)
    LevelVisitCheck.new(levels)
  end

  # Checks for a particular node during network visit.
  class NodeVisitCheck < VisitCheck
    def initialize(nodes)
      @nodes = nodes
    end

    def call(node_info)
      @nodes.include?(node_info.node)
    end
  end

  def node(*nodes)
    NodeVisitCheck.new(nodes)
  end

  # Checks for a particular marker for edge visit.
  class MarkerVisitCheck < VisitCheck
    def initialize(markers)
      @markers = markers
    end

    def call(edge)
      @markers.include?(edge.marker)
    end
  end

  def marker(*markers)
    MarkerVisitCheck.new(markers)
  end

  # Checks for a particular ticket for edge visit.
  class TicketVisitCheck < VisitCheck
    def initialize(tickets)
      @tickets = tickets
    end

    def call(edge)
      @tickets.include?(edge.ticket)
    end
  end

  def ticket(*tickets)
    TicketVisitCheck.new(tickets)
  end

  # Checks for a particular node origin.
  class OriginVisitCheck < VisitCheck
    def initialize(origins)
      @origins = origins
    end

    def call(node_info)
      @origins.include?(node_info.node.origin)
    end
  end

  def origin(*origins)
    OriginVisitCheck.new(origins)
  end

  # Unary operation, applied to a visit check.
  class UnaryOpVisitCheck < VisitCheck
    def initialize(check)
      @check = check
    end
  end

  # Unary negation, applied to a visit check.
  class NotOpVisitCheck < UnaryOpVisitCheck
    def call(origin)
      not @check.call(origin)
    end
  end

  # Binary operation, applied to two visit checks.
  class BinaryOpVisitCheck < VisitCheck
    def initialize(check1, check2)
      @check1 = check1
      @check2 = check2
    end
  end

  # Binary 'and' operation, applied to two checks.
  class AndOpVisitCheck < BinaryOpVisitCheck
    def call(origin)
      @check1.call(origin) and @check2.call(origin)
    end
  end

  # Binary 'or' operation, applied to two checks.
  class OrOpVisitCheck < BinaryOpVisitCheck
    def call(origin)
      @check1.call(origin) or @check2.call(origin)
    end
  end
end
