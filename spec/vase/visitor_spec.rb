require 'spec_helper'

module Vase
  describe Visitor do
    include Vase

    def check_nodes(actual, nodes)
      actual.should eq nodes
    end

    before :each do
      @policy1 = visit_policy goes_not_beyond: level(1),
                              stops_at: none,
                              goes_through: any

      @policy2 = visit_policy goes_not_beyond: level(0),
                              stops_at: none,
                              goes_through: any
      
      @policy3 = visit_policy goes_not_beyond: none,
                              stops_at: none,
                              goes_through: ticket(:@left, :@right)
      
      @network = ObjectNetwork.new
      @a = @network.node([1, 2])
      @e1 = @network.node(1)
      @e2 = @network.node(2)
    end

    it 'should visit array' do
      a = @network.node([1, 2])
      a0 = @network.node(1)
      a1 = @network.node(2)
      visitor1 = Visitor.new(@policy1, a)
      visitor1.visit_all()
      check_nodes(visitor1.nodes,
                  [a, a0, a1])
      visitor2 = Visitor.new(@policy2, a)
      visitor2.visit_all()
      check_nodes(visitor2.nodes,
                  [a])
      visitor3 = Visitor.new(@policy3, a)
      visitor3.visit_all()
      check_nodes(visitor3.nodes,
                  [a])
    end

    it 'should recursively visit a binary tree' do
      a = TestTree.new(nil, nil)
      b = TestTree.new(a, nil)
      an = @network.node(a)
      bn = @network.node(b)
      nn = @network.node(nil)

      visitor = Visitor.new(@policy3, bn)
      visitor.visit_all()
      check_nodes(visitor.nodes,
                  [bn, an, nn])

      visitor2 = Visitor.new(@policy2, bn)
      visitor2.visit_all()
      check_nodes(visitor2.nodes,
                  [bn])
    end
  end
end
