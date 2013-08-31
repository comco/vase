# Flow control primitives.
module Vase

  class Flow
    attr_reader :name
    
    def initialize(name)
      @name = name
      @sections = {}
    end

    def new_section(name)
      Section.new(name, self)
    end

    def get_section(name)
      unless @sections.has_key?(name)
        @sections[name] = new_section(name)
      end
      @sections[name]
    end

    def section(name, options = {})
      s = get_section(name)
      s.before()
      yield
      s.after()
    end

    def [](name)
      @sections[name]
    end
  end

  # Creates and executes a flow.
  def flow(name, &block)
    f = Flow.new(name)
    f.instance_eval(&block)
    f
  end

  # Represents a controllable secion of code, which can be stopped at.
  class Section
    attr_reader :name, :flow, :hits
    def initialize(name, flow)
      @name = name
      @flow = flow
      @hits = 0
    end

    def before
      # do nothing.
    end

    def after
      @hits += 1
    end
  end
end
