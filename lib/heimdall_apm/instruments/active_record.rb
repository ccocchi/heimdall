require 'heimdall_apm/utils/ar_metric_name'

module HeimdallApm
  module ActiveRecord
    class Subscriber
      def start(name, id, payload)
        txn     = ::HeimdallApm::TransactionManager.current
        segment = ::HeimdallApm::Segment.new('Sql'.freeze, name)
        segment.data = payload[:sql]

        txn.start_segment(segment)
      end

      def finish(name, id, payload)
        txn     = ::HeimdallApm::TransactionManager.current
        segment = txn.current_segment

        txn.stop_segment
        segment.name = Utils::ARMetricName.from_payload(payload) || 'other'.freeze
      end
    end
  end
end

ActiveSupport::Notifications.subscribe(
  'sql.active_record',
  ::HeimdallApm::ActiveRecord::Subscriber.new
)
