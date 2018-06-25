module HeimdallApm
  module Instruments
    class Middleware
      def initialize(app)
        @app = app
      end

      def call(env)
        txn     = ::HeimdallApm::TransactionManager.current
        segment = ::HeimdallApm::Segment.new('Middleware'.freeze, 'all'.freeze)
        txn.start_segment(segment)
        @app.call(env)
      ensure
        txn.stop_segment
      end
    end
  end
end
