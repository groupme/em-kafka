require "eventmachine"
require "logger"
require "em-kafka/client"

module EventMachine
  module Kafka
    class << self
      def logger
        @logger ||= Logger.new(STDOUT)
      end

      def logger=(new_logger)
        @logger = new_logger
      end
    end
  end
end
