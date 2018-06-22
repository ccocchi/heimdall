module HeimdallApm
  class Segment
    # Generic type of the thing being tracked
    #   Examples: "ActiveRecord", "SQL", "Controller"
    attr_reader :type

    # More specific name of the item
    #   Examples: "User#find", "find_by_sql", "users#index"
    attr_reader :name

    # Start and stop of this segment
    attr_reader :start_time, :stop_time

    # TODO: add annotations to the segment for custom data
    # attr_reader :annotations

    def initialize(type, name, start_time = nil)
      @type       = type
      @name       = name
      @start_time = start_time || Process.clock_gettime(Process::CLOCK_REALTIME)
      @children   = nil
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
      @children.each { |c| c.accept(visitor) } if @children
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
