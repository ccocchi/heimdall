module HeimdallApm
  module Visitors
    class PrettyPrintVisitor
      def initialize(*args)
        @indent = 0
        @io     = File.open('log/heimdall_apm.log', 'ab')
        @total  = 0
        at_exit { @io.close }
      end

      def before_children
        @indent += 2
      end

      def after_children
        @indent -= 2
      end

      def visit(segment)
        pprint("#{segment.type}/#{segment.name}\n")
        @indent += 2
        # pprint("start_time=#{segment.start_time}\n")
        # pprint("stop_time=#{segment.stop_time}\n")
        pprint("#{segment.data}\n") if segment.data
        pprint("duration=#{(segment.total_exclusive_time * 1000).round(1)}ms\n")
        @indent -= 2
        @total += segment.total_exclusive_time
      end

      def store_in_vault
        pprint("Total: #{@total * 1000}ms\n")
        @io.flush
      end

      private

      def pprint(str)
        @io.write(' ' * @indent) if @indent > 0
        @io.write(str)
      end

    end
  end
end
