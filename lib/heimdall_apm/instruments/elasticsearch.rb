module HeimdallApm
  module Elasticsearch
    class Subscriber
      def start(name, id, payload)
        txn     = ::HeimdallApm::TransactionManager.current
        segment = ::HeimdallApm::Segment.new('Elastic'.freeze, name)
        segment.data = payload[:search]

        txn.start_segment(segment)
      end

      def finish(name, id, payload)
        txn = ::HeimdallApm::TransactionManager.current
        txn.stop_segment
      end
    end
  end
end

ActiveSupport::Notifications.subscribe(
  'search.elasticsearch',
  ::HeimdallApm::Elasticsearch::Subscriber.new
)
