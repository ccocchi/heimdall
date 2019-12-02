# frozen_string_literal: true

module HeimdallApm
  module Utils
    module ARMetricName
      def self.from_payload(payload)
        name = payload[:name]
        return name unless name

        model, operation = name.split(' '.freeze)
        return nil if model == 'SCHEMA'

        operation = parse_operation(operation) if operation
        "#{model}##{operation}"
      end

      private

      def self.parse_operation(op)
        case op
        when 'Load'   then 'find'
        when 'Update' then 'save'
        else
          -op.downcase
        end
      end
    end
  end
end
