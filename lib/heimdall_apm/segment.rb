module HeimdallApm
  class Segment
    # Generic type of the thing being tracked
    #   Examples: "ActiveRecord", "SQL", "Controller"
    attr_reader :type

    # More specific name of the item
    #   Examples: "User#find", "find_by_sql", "users#index"
    attr_accessor :name

    # Start and stop of this segment
    attr_reader :start_time, :stop_time

    # Additional data linked to the segment (for example SQL or Elastic queries).
    # Can be left nil.
    attr_accessor :data

    def initialize(type, name, start_time = nil)
      @type       = type
      @name       = name
      @start_time = start_time
      @children   = nil
    end

    def start
      @start_time = Process.clock_gettime(Process::CLOCK_REALTIME)
    end

    # Lazy initialization of children to avoid bloating leaf segments
    def children
      @children ||= []
    end

    def add_child(segment)
      children << segment
    end

    # Entry point for visitors depth-first style: start by visiting `self` then
    # visit all of its children
    def accept(visitor)
      visitor.visit(self)
      if @children
        visitor.before_children if visitor.respond_to?(:before_children)
        @children.each { |c| c.accept(visitor) }
        visitor.after_children if visitor.respond_to?(:after_children)
      end
    end

    def record_stop_time
      @stop_time = Process.clock_gettime(Process::CLOCK_REALTIME)
    end

    def total_call_time
      @total_call_time ||= stop_time - start_time
    end

    def total_exclusive_time
      return total_call_time unless @children
      total_call_time - children_call_time
    end

    private

    def children_call_time
      children.map(&:total_call_time).sum
    end
  end
end
