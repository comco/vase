require 'spec_helper'

module Vase
  describe ObjectNetwork do
    def check_class(origin, klass)
      @network.node(origin).class.should eq klass
    end
    
    def check_edges(origin, edges)
      a = @network.node(origin)
      actual = a.edges.map do |edge|
        [edge.source.origin, edge.target.origin, edge.marker, edge.ticket]
      end
      actual.should eq edges
    end

    before :each do
      @network = ObjectNetwork.new
    end

    it 'should build arrays' do
      check_class([1, 2], ArrayNode)
    end

    it 'should build hashes' do
      check_class({a: 3, b: 4}, HashNode)
    end

    it 'should build simple types' do
      check_class(nil, SimpleNode)
      check_class(2, SimpleNode)
      check_class('ala', SimpleNode)
    end

    it 'should build structs' do
      check_class(TestStruct.new(1, 2, 3), StructNode)  
      check_class(TestTree.new(:a, :b), StructNode)
    end

    it 'should build array edges properly' do
      a = [1, 2]
      check_edges(a, [
                  [a, 1, :array_edge, 0],
                  [a, 2, :array_edge, 1]])
    end

    it 'should build hash edges properly' do
      h = {a: 3, b: 4}
      check_edges(h, [
                  [h, 3, :hash_edge, :a],
                  [h, 4, :hash_edge, :b]])
    end

    it 'should build struct edges properly' do
      s = TestStruct.new(5, 6, 7)
      check_edges(s, [
                  [s, 5, :struct_edge, :@x],
                  [s, 6, :struct_edge, :@y],
                  [s, 7, :struct_edge, :@z]])
    end

    it 'should have no edges on simple types' do
      check_edges(1, [])
      check_edges(nil, [])
      check_edges('ala', [])
    end
  end
end
