require "eventmachine"
require "logger"
require "uri"
require "oj"

require_relative "em-kafka/event_emitter"
require_relative "em-kafka/connection"
require_relative "em-kafka/client"
require_relative "em-kafka/message"
require_relative "em-kafka/producer"
require_relative "em-kafka/consumer"

module EventMachine
  module Kafka
    MESSAGE_MAX_SIZE = 1048576 # 1 MB
    CONSUMER_POLLING_INTERVAL = 2 # 2 seconds

    REQUEST_PRODUCE      = 0
    REQUEST_FETCH        = 1
    REQUEST_MULTIFETCH   = 2
    REQUEST_MULTIPRODUCE = 3
    REQUEST_OFFSETS      = 4

    ERROR_NO_ERROR                = 0
    ERROR_OFFSET_OUT_OF_RANGE     = 1
    ERROR_INVALID_MESSAGE_CODE    = 2
    ERROR_WRONG_PARTITION_CODE    = 3
    ERROR_INVALID_RETCH_SIZE_CODE = 4

    ERROR_DESCRIPTIONS = {
      ERROR_NO_ERROR                => 'No error',
      ERROR_INVALID_MESSAGE_CODE    => 'Offset out of range',
      ERROR_INVALID_MESSAGE_CODE    => 'Invalid message code',
      ERROR_WRONG_PARTITION_CODE    => 'Wrong partition code',
      ERROR_INVALID_RETCH_SIZE_CODE => 'Invalid retch size code'
    }

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
