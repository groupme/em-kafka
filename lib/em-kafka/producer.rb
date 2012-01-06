module EventMachine
  module Kafka
    class Producer
      require_relative "producer_request"
      attr_accessor :host, :port, :topic, :partition, :client

      def initialize(uri)
        uri = URI(uri)
        self.host = uri.host
        self.port = uri.port
        self.topic = uri.user
        self.partition = uri.path[1..-1].to_i

        raise ArgumentError("topic required") unless topic

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
