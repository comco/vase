require 'spec_helper'

module Vase
  describe Flow do
    include Vase

    it 'should be able to create and execute a Flow' do
      i = 0
      flow 'flow' do
        i = 10
      end
      i.should eq 10
    end

    it 'should be able to execute flows with sections' do
      i = 0
      f = flow 'flow' do
        section 'a' do
          i = 10
        end
      end
      i.should eq 10
      f['a'].hits.should eq 1
    end

    it 'should be able to execute complex flows' do
      s = n = nil
      f = flow 'count' do
        section 'initialize' do
          s = 0
          n = 10
        end
        (1..n).each do |i|
          section 'add' do
            s += i
          end
        end
      end
      s.should eq 55 
      f['initialize'].hits.should eq 1
      f['add'].hits.should eq 10
    end
  end
end
