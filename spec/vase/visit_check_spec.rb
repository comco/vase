require 'spec_helper'
require 'vase/visit_check'

module Vase
  describe VisitCheck do
    include Vase

    before :each do
      @network = ObjectNetwork.new
      @node_1 = @network.node(1)
      @node_a = @network.node([1, 2])
      @node_info_a = NodeInfo.new_root(@node_a)
      @node_info_1 = NodeInfo.new(@node_1, @node_a, 0, 1)
    end

    it 'should work for constant checks' do
      none.call(@node_info_a).should be_false
      any.call(@node_info_a).should be_true
    end

    it 'should check for level' do
      level().call(@node_info_a).should be_false

      level(0).call(@node_info_a).should be_true
      level(1).call(@node_info_a).should be_false
      level(0).call(@node_info_1).should be_false
      level(1).call(@node_info_1).should be_true

      level(0, 2).call(@node_info_a).should be_true
      level(3, 4).call(@node_info_1).should be_false
    end

    it 'should check for node' do
      node(@node_1).call(@node_info_1).should be_true
      node(@node_1).call(@node_info_a).should be_false
      node(@node_1, @node_a).call(@node_info_a).should be_true
      node().call(@node_info_1).should be_false
    end

    it 'should check for origin' do
      origin(1).call(@node_info_1).should be_true
      origin(1).call(@node_info_a).should be_false
    end

    it 'should check for a ticket' do
      ticket(0).call(@node_a.edge(0)).should be_true
      ticket(0, 1).call(@node_a.edge(1)).should be_true
    end

    it 'should check for a marker' do
      marker(:array_edge).call(@node_a.edge(0)).should be_true
      marker(:hash_edge).call(@node_a.edge(1)).should be_false
    end

    it 'should check for target' do
      target(@node_a.node(0)).call(@node_a.edge(0)).should be_true
      target(@node_a.node(0)).call(@node_a.edge(1)).should be_false
    end

    it 'should work with not' do
      node(@node_1).not.call(@node_info_1).should be_false
      node(@node_1).not.call(@node_info_a).should be_true
    end

    it 'should work with and' do
      node(@node_1).and(level(1)).call(@node_info_1).should be_true
      node(@node_1).and(level(0)).call(@node_info_1).should be_false
    end

    it 'should work with or' do
      node(@node_a).or(level(1)).call(@node_info_1).should be_true
      node(@node_1).or(level(1)).call(@node_info_a).should be_false
    end
  end
end
