# Proof-of-concept scribbles.
require 'graphviz'

g = GraphViz.new type: 'digraph'
a = g.add_nodes('A', label: '<1>A|<2>B', shape: 'record')
b = g.add_nodes('B')

g.add_edges({a => '2'}, b)

g.output png: 'poc.png'

class Section
  attr_reader :env, :name
  
  def initialize(env, name)
    @env = env
    @name = name
  end

  def before
    puts "before section #{name}"
  end

  def after
    puts "after section #{name}"
  end
end

class Env
  def initialize()
    @sections = {}
  end

  def get_section(name)
    unless @sections.has_key?(name)
      @sections[name] = Section.new(self, name)
    end
    @sections[name]
  end

  def section(name)
    s = get_section(name)
    s.before
    yield
    s.after
  end
end

def omgwtf(&block)
  env = Env.new
  env.instance_eval(&block)
end

omgwtf do
  i = 10
  (1..10).each do |turn|
    section("test section") do
      i += 1
    end
    puts i
  end
end
