module HeimdallApm
  module ActionController
    class Subscriber
      def start(name, id, payload)
        txn     = ::HeimdallApm::TransactionManager.current
        scope   = -"#{payload[:controller]}##{payload[:action]}"
        segment = ::HeimdallApm::Segment.new('Controller'.freeze, scope)

        # Don't override scope if already set. Should never happen in practice
        # unless a controller calls another action.
        txn.scope = scope unless txn.scope

        # Rails gives us Request#fullpath
        txn.annotate({ uri: extract_path(payload[:path]) })

        txn.start_segment(segment)
      end

      def finish(name, id, payload)
        txn = ::HeimdallApm::TransactionManager.current
        txn.stop_segment
      end

      private

      def extract_path(fullpath)
        i = fullpath.index('?'.freeze)
        i ? fullpath.slice(0, i) : fullpath
      end
    end
  end
end

ActiveSupport::Notifications.subscribe(
  'process_action.action_controller',
  ::HeimdallApm::ActionController::Subscriber.new
)
