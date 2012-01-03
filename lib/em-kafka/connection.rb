module EventMachine::Kafka
  class Connection < EM::Connection
    include EventMachine::Kafka::EventEmitter

    def initialize(host, port)
      super
      @host, @port = host, port
    end

    def connection_completed
      EventMachine::Kafka.logger.info("Connected to Kafka")
      emit(:connected)
    end

    def receive_data(data)
      emit(:message, data)
    end

    def unbind
      EventMachine::Kafka.logger.info("Disconnected from Kafka")
      emit(:closed)
    end
  end
end
