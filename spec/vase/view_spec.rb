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
  end
end
