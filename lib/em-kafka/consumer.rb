module EventMachine
  module Kafka
    class Consumer
      require_relative "consumer_request"
      require_relative "parser"

      attr_accessor :topic,
                    :partition,
                    :offset,
                    :max_size,
                    :request_type,
                    :polling,
                    :client,
                    :host,
                    :port

      def initialize(options = {})
        self.host         = options[:host]
        self.port         = options[:port]
        self.topic        = options[:topic]        || "test"
        self.partition    = options[:partition]    || 0
        self.offset       = options[:offset]       || 0
        self.max_size     = options[:max_size]     || EM::Kafka::MESSAGE_MAX_SIZE
        self.request_type = options[:request_type] || EM::Kafka::REQUEST_FETCH
        self.polling      = options[:polling]      || EM::Kafka::CONSUMER_POLLING_INTERVAL
        self.client = EM::Kafka::Client.new(host, port)
        client.connect
      end

      def consume(&block)
        raise ArgumentError.new("block required") unless block_given?
        parser = EM::Kafka::Parser.new(offset, &block)
        parser.on_offset_update { |i| self.offset = i }
        client.on_data { |binary| parser.on_data(binary) }
        EM.add_periodic_timer(polling) { request_consume }
      end

      private

      def request_consume
        request = EM::Kafka::ConsumerRequest.new(request_type, topic, partition, offset, max_size)
        client.send_data(request.encode_size)
        client.send_data(request.encode)
      end
    end
  end
end
