module HeimdallApm
  module Instruments
    class MiddlewareWrapper
      def initialize(app, name)
        @app  = app
        @name = name
      end

      def call(env)
        txn     = ::HeimdallApm::TransactionManager.current
        segment = ::HeimdallApm::Segment.new('Middleware'.freeze, @name)
        txn.start_segment(segment)
        @app.call(env)
      ensure
        txn.stop_segment
      end
    end
  end
end

ActionDispatch::MiddlewareStack::Middleware.class_eval do
  def build(app)
    middleware = klass.new(app, *args, &block)
    ::HeimdallApm::Instruments::MiddlewareWrapper.new(middleware, klass.name)
  end
end
