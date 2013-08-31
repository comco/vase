require 'spec_helper'

module Vase
  describe Presentation do
    include Vase

    it 'should create and execute a presentation' do
      # Output the result in the 'results' directory.
      p = Presentation.new('spec/images')
      
      # Create a simple tree view.
      p.add_part('Tree',
                 node_visit_policy(goes_not_beyond: none,
                                   goes_through: any,
                                   stops_at: none),
                 node_view_policy,
                 :root)

      # Create the tree edges.
      p.add_connection('Tree Connections',
                       'Tree',
                       'Tree')

      # Execute the algorithm.
      p.flow 'Build a tree' do
        a = TestTree.new(nil, nil)
        b = a
        (10..14).each do |i|
          section 'tree_build', root: a do
            b.left = TestTree.new(nil, i)
            b = b.left
          end
        end
      end
    end
  end
end
