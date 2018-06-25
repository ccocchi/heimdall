module HeimdallApm
  module ActionController
    class Subscriber
      def start(name, id, payload)
        txn     = ::HeimdallApm::TransactionManager.current
        segment = ::HeimdallApm::Segment.new('Controller'.freeze, )
        txn.start_segment(segment)
      end

      def finish(name, id, payload)
        txn = ::HeimdallApm::TransactionManager.current
        txn.stop_segment
      end
    end
  end
end



process_action.action_controller
