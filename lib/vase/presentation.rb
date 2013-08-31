require 'vase/object_network'
require 'vase/visitor'
require 'vase/view'
require 'vase/flow'
require 'graphviz'

module Vase
  # View for a set of nodes.
  class NodeViewPolicy
    def view(name, graph, nodes)
      GraphVizView.new(name, graph, nodes)
    end
  end

  # Creates a new view for a set of nodes.
  def node_view_policy
    NodeViewPolicy.new
  end

  # Policy for visiting nodes.
  class NodeVisitPolicy
    include Vase

    def initialize(options)
      @options = options
    end

    def visitor(name, origin)
      @origin = origin
      self
    end

    def visit()
      visitor = Visitor.new(visit_policy(@options), @origin)
      visitor.visit_all()
      visitor.nodes()
    end
  end

  # Creates a new visit policy for visiting a set of nodes.
  def node_visit_policy(options)
    NodeVisitPolicy.new(options)
  end

  # A specialization of a Section for the presentation capabilities.
  class PresentationSection < Section
    def initialize(name, flow, presentation)
      @name = name
      @flow = flow
      @presentation = presentation
      super(name, flow)
    end

    def after()
      @presentation.draw_graph(name, hits)
      super
    end
  end

  # A presentation part, representing a collection of nodes and
  # a view to display them.
  class PresentationPart
    attr_reader :name,
                :presentation,
                :visit_policy,
                :view_policy,
                :origin_key

    def initialize(name,
                   presentation,
                   visit_policy,
                   view_policy,
                   origin_key)
      @name = name
      @presentation = presentation
      @visit_policy = visit_policy
      @view_policy = view_policy
      @origin_key = origin_key
    end

    def draw(graph)
      origin = @presentation.node(@origin_key)
      visitor = @visit_policy.visitor(name, origin)
      @presentation.visitors[name] = visitor
      view = @view_policy.view(name, graph, visitor.visit())
      @presentation.views[name] = view
      view.draw()
    end
  end

  # A presentation connection, representing
  # edges between two presentation views.
  class PresentationPartConnection
    include Vase

    attr_reader :presentation,
                :source_view_key,
                :target_view_key,
                :connection_policy # TODO: Unused for now.

    def initialize(presentation,
                   source_view_key,
                   target_view_key,
                   connection_policy)
      @presentation = presentation
      @source_view_key = source_view_key
      @target_view_key = target_view_key
      @connection_policy = connection_policy
    end

    def source_view
      @presentation.views[@source_view_key]
    end

    def target_view
      @presentation.views[@target_view_key]
    end

    def draw(graph)
      connect(source_view, target_view)
    end
  end

  # A presentation-specialized flow.
  class PresentationFlow < Flow
    def initialize(name, presentation)
      super(name)
      @presentation = presentation
    end

    def new_section(name)
      PresentationSection.new(name, self, @presentation)
    end

    def section(name, options = {})
      options.each do |key, value|
        @presentation.values[key] = value
      end
      super(name)
    end
  end

  # An all-in-one class for executing a sectioned program and collecting
  # the resulting graphics in a directory.
  class Presentation
    attr_reader :dir, :values, :views, :visitors

    # Initializes a presentation, writing its results to the given
    # directory.
    def initialize(dir)
      @dir = dir
      Dir.mkdir dir unless Dir.exists? dir
      @network = ObjectNetwork.new
      @values = {}
      @views = {}
      @visitors = {}
      @parts = {}
    end

    # Executes a given flow.
    def flow(name, &block)
      @flow = PresentationFlow.new(name, self)
      @flow.instance_eval(&block)
    end

    # Returns the node with a given key.
    def node(key)
      @network.node(@values[key])
    end

    # Adds connections between views.
    def add_connection(name, source_view_key, target_view_key)
      @parts[name] = PresentationPartConnection.new(self,
                                                    source_view_key,
                                                    target_view_key,
                                                    nil)
    end

    # Draws the graph to the file system.
    def draw_graph(section_name, hits)
      # puts "draw_graph: #{section_name}, #{hits}"
      graph = GraphViz.new type: 'digraph'
      @parts.each do |name, part|
        part.draw(graph)
      end
      graph.output png: "#@dir/#{section_name}_#{hits}.png"
    end

    def add_part(name, visit_policy, view_policy, origin_key)
      @parts[name] = PresentationPart.new(name, 
                                          self, 
                                          visit_policy, 
                                          view_policy, 
                                          origin_key)
    end
  end
end
