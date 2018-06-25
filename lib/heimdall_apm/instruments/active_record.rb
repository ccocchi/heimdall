module HeimdallApm
  module ActiveRecord
    class Subscriber
      def start(name, id, payload)
        txn     = ::HeimdallApm::TransactionManager.current
        segment = ::HeimdallApm::Segment.new('ActiveRecord'.freeze, name)
        txn.start_segment(segment)
      end

      def finish
        txn = ::HeimdallApm::TransactionManager.current
        txn.stop_segment
      end
    end
  end
end

ActiveSupport::Notifications.subscribe(
  'sql.active_record',
  ::HeimdallApm::ActiveRecord::Subscriber.new
)
