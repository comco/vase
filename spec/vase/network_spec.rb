require 'spec_helper'

module Vase
  describe Node do
    it 'should have a readable origin' do
      n = Node.new(:origin)
      n.origin.should eq :origin
    end
  end

  describe Edge do
    it 'should have readable fields and equality' do
      e = Edge.new(1, 2, :mark, :tick)
      e.source.should eq 1
      e.target.should eq 2
      e.marker.should eq :mark
      e.ticket.should eq :tick

      f = Edge.new(1, 2, :mark, :tick)
      e.should eq f
      f.should_not eq Edge.new(2, 1, :mark, :tick)
    end
  end
end
