module HeimdallApm
  module Instruments
    class SidekiqMiddleware
      def call(_worker, item, queue, redis_pool = nil)
        txn     = ::HeimdallApm::TransactionManager.current
        txn.annotate(latency: latency(item))
        txn.scope = unwrapped_worker_name(item)

        segment = ::HeimdallApm::Segment.new('Job'.freeze, 'all'.freeze)
        txn.start_segment(segment)

        yield
      ensure
        txn.stop_segment
      end

      private

      def unwrapped_worker_name(item)
        item['wrapped'] || item['class']
      end

      def latency(item)
        created_at = item['enqueued_at'] || item['created_at']
        if created_at
          (Time.now.to_f - created_at)
        else
          0.0
        end
      rescue
        0.0
      end
    end
  end
end

Sidekiq.configure_server do |config|
  config.server_middleware do |chain|
    chain.add HeimdallApm::Instruments::SidekiqMiddleware
  end
end
