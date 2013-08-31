require 'spec_helper'

module Vase
  describe View do
    include Vase

    before :each do
      @graph = GraphViz.new type: 'digraph'
      @visit_policy = visit_policy goes_not_beyond: none,
                                   stops_at: none,
                                   goes_through: any

      @network = ObjectNetwork.new
      a = [1, {h: [8, 3, nil]}, TestTree.new(nil, nil)]
      @visitor = Visitor.new(@visit_policy, @network.node(a))
      @visitor.visit_all()
      @view = GraphVizView.new('view', @graph, @visitor.nodes)
      @view.draw()
    end

    it 'should create an image' do
      connect(@view, @view)
      @graph.output png: 'spec/images/view_test1.png'
    end

    it 'should create an array view' do
      graph = GraphViz.new type: 'digraph'
      a = [1, 2, 3]
      an = @network.node(a)
      array_view = ArrayGraphVizView.new('array', graph, an.edges)
      array_view.draw()
      # Create some edges to ensure visuals are correct
      graph.add_edges(array_view.visual(@network.node(1)),
                      array_view.visual(@network.node(3)))
      graph.add_edges(array_view.visual(@network.node(2)),
                      array_view.visual(@network.node(1)))
      graph.output png: 'spec/images/view_test2.png'
    end

    it 'should be able to display combined views' do
      graph = GraphViz.new type: 'digraph'
      a = [1, 2, 3]
      a_node = @network.node(a)
      node_view = GraphVizView.new('root', graph, [a_node])
      array_view = ArrayGraphVizView.new('elements', graph, a_node.edges)
      node_view.draw()
      array_view.draw()
      connect(node_view, array_view)
      graph.output png: 'spec/images/view_test3.png'
    end
  end
end
