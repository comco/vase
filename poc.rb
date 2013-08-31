# Proof-of-concept scribbles.
require 'graphviz'

g = GraphViz.new type: 'digraph'
a = g.add_nodes('A', label: '<1>A|<2>B', shape: 'record')
b = g.add_nodes('B')

g.add_edges({a => '2'}, b)

g.output png: 'poc.png'
