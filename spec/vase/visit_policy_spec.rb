require 'spec_helper'

module Vase
  describe VisitPolicy do
    before :each do
      @policy = VisitPolicy.new
    end
    
    it 'should behave in nice way' do
      @policy.goes_not_beyond(:node).should be_false
      @policy.stops_at(:node).should be_false
      @policy.goes_through(:edge).should be_true
    end

    it 'should control visit correctly' do
      @policy.visit_node(nil).should eq :step_into
      @policy.visit_edge(nil).should eq :step_into
    end

    it 'should create a bag' do
      @policy.new_bag(nil).class.should eq BFS
    end
  end

  describe SingleTimeVisitPolicy do
    before :each do
      @policy = SingleTimeVisitPolicy.new
    end

    it 'should visit only once' do
      @policy.visit_node(NodeInfo.new_root(:a)).should eq :step_into
      @policy.visit_edge(Edge.new(nil, :a, nil, nil)).should eq :step_over
    end
  end

  describe FlexibleVisitPolicy do
    include Vase

    before :each do
      @network = ObjectNetwork.new
      @a = @network.node([1, 2])
      @ai = NodeInfo.new_root(@a)
      @e = @network.node(1)
      @ei = @ai.new_node_info(0)
      @s = @network.node('stop')
      @si = NodeInfo.new_root(@s)
      @policy = visit_policy goes_not_beyond: level(1),
                             stops_at: node(@s),
                             goes_through: marker(:array_edge)
    end

    it 'should check for not beyond' do
      @policy.visit_node(@ai).should eq :step_into 
      @policy.visit_node(@ei).should eq :step_over
    end

    it 'should check for stops at' do
      @policy.visit_node(@si).should eq :stop
    end

    it 'should check for goes through' do
      @policy.visit_edge(@a.edge(0)).should eq :step_into
      @policy.visit_edge(Edge.new(nil, nil, nil, nil)).should eq :step_over
    end
  end
end
