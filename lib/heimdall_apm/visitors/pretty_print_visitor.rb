module HeimdallApm
  module Visitors
    class PrettyPrintVisitor
      def initialize(scope)
        @indent = 0
        @scope  = scope

        @io     = File.open('log/heimdall_apm.log', 'ab')
        at_exit { @io.close }

        pprint("Request #{scope}:\n")
      end

      def before_children
        @indent += 2
      end

      def after_children
        @indent -= 2
      end

      def visit(segment)
        pprint("#{segment.type}/#{segment.name}")
      end

      def store_in_vault
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
