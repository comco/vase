# Views functionality.
module Vase
  # Base class for views.
  class View
    attr_reader :name

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
      node.origin.to_s
    end

    def visual(node)
      @visuals[node]
    end
  end

  class GraphVizView < View
    attr_reader :graph, :nodes

    def initialize(name, graph, nodes)
      super(name)
      @graph = graph
      @nodes = nodes
    end

    def draw()
      @nodes.each do |node|
        @visuals[node] = @graph.add_nodes(node_id(node), 
                                          label: node_label(node))
      end
    end
  end

  class ArrayGraphVizView < View
    attr_reader :graph, :edges

    def initialize(name, graph, edges)
      super(name)
      @graph = graph
      @edges = edges
    end

    def nodes
      edge.map(&:target)
    end

    def draw()
      array_visual = @graph.add_nodes(node_name(), shape: 'record')
      edges.each do |edge|
        @visuals[edge.target] = {array_visual => edge_id(edge) }
      end
    end

    def node_name()
      node_names = edges.map do |edge|
        node = edge.target
        "<#{edge_id(edge)}>#{node_label(node)}"
      end
      node_names.join('|')
    end

    def edge_id(edge)
      edge.ticket.to_s
    end
  end

  # Connects the network nodes from the source view to the target view.
  def connect(source_view, target_view)
    graph = source_view.graph
    source_view.nodes.each do |source_node|
      source_visual = source_view.visual(source_node)
      source_node.edges.each do |edge|
        target_visual = target_view.visual(edge.target)
        unless target_visual.nil?
          graph.add_edge(source_visual, 
                         target_visual,
                         label: edge.ticket.to_s)
        end
      end
    end
  end
end
