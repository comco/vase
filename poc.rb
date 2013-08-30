# Proof-of-concept scribbles.
require 'graphviz'

g = GraphViz.new type: 'digraph'
a = g.add_nodes('A')
b = g.add_nodes('B')

g.add_edges(a, b)

g.output png: 'poc.png'
