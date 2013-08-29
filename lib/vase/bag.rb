# Bags flavors used in network visit.
module Vase

  # Queue implementation.
  class Queue
    def initialize(*contents)
      @queue = contents
    end

    def push(object)
      @queue.push(object)
    end

    def pop()
      @queue.shift
    end

    def empty?
      @queue.empty?
    end

    def clear
      @queue.clear
    end
  end
  
  # Use a queue for BFS graph traversal.
  BFS = Queue

  # Arrays act as stacks.
  Stack = Array

  # Use a stack for DFS graph traversal.
  DFS = Stack

end
