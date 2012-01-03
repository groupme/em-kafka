module EventMachine
  module Kafka
    class Producer
      require_relative "producer_request"
      attr_accessor :host, :port, :topic, :partition, :client

      def initialize(options = {})
        raise ArgumentError(":topic required") unless options[:topic]
        self.host = options[:host]
        self.port = options[:port]
        self.topic = options[:topic]
        self.partition = options[:partition] || 0
        self.client = EM::Kafka::Client.new(host, port)
        client.connect
      end

      def deliver(message)
        request = EM::Kafka::ProducerRequest.new(topic, partition, message)
        client.send_data(request.encode)
      end
    end
  end
end
