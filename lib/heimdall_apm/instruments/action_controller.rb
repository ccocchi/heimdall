module HeimdallApm
  module ActionController
    class Subscriber
      def start(name, id, payload)
        txn     = ::HeimdallApm::TransactionManager.current
        scope   = -"#{payload[:controller]}/#{payload[:action]}"
        segment = ::HeimdallApm::Segment.new('Controller'.freeze, scope)

        txn.scope = scope unless txn.scope
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
  'process_action.action_controller',
  ::HeimdallApm::ActionController::Subscriber.new
)
