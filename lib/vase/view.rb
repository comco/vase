# Views functionality.
module Vase
  # A base view class, representing a view of nodes in a visual graph.
  # A concrete implementation should support the method for_nodes, which 
  class ViewPolicy
  end

  class View
    def initialize(name)
      @name = name
      @visuals = {}
    end

    # Returns a node identifier.
    def node_id(node)
      name + '_' + node.to_s
    end

    # Returns a node label.
    def node_label(node)
      node.to_s
    end

    def add_visual(node, visual)
      @visuals[node] = visual
    end
  end

  class GraphvizView < View
    def initialize(nodes, graph, policy)
      @nodes = nodes
      @graph = graph
      @policy = policy
      @visuals = {}
    end

    # Draws the view to the graph.
    def draw
      @nodes.each do |node|
        visual = @graph.add_nodes(node_id(node), label: node_label(node))
        add_visual(node, visual)
      end
    end
  end
end
