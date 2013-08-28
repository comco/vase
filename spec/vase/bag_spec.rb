require 'spec_helper'

module Vase

  describe Queue do
    it 'should be FILO' do 
      q = Queue.new
      q.push(1)
      q.push(2)
      q.pop().should eq 1
      q.empty?.should be_false
      q.pop().should eq 2
      q.empty?.should be_true
    end
  end

  describe Stack do
    it 'should be FIFO' do
      s = Stack.new
      s.push(1)
      s.push(2)
      s.pop().should eq 2
      s.empty?.should be_false
      s.pop().should eq 1
      s.empty?.should be_true
    end
  end

end
