module HeimdallApm
  class Reporting
    def initialize(context)
      @context = context
    end

    # TODO: make this configurable
    def influx
      @client ||= InfluxDB::Client.new("#{Rails.env}_metrics", time_precision: 'ms', retry: 0)
    end

    def call
      span = @context.vault.retrieve_and_delete_previous_span
      if span && !span.points_collection.empty?
        influx.write_points(span.points_collection.to_a)
      else
        @context.logger.debug "Nothing to report"
      end
    rescue => e
      @context.logger.error "#{e.message} during reporting to InfluxDB"
    end
  end
end
