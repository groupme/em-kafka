module EventMachine
  module Kafka
    class Client
      include EventMachine::Kafka::EventEmitter
      include EM::Deferrable

      def initialize(host = 'localhost', port = 9092)
        @host, @port = host, port
        @closing_connection = false
      end

      def connect
        @connection = EM.connect(@host, @port, EM::Kafka::Connection, @host, @port)

        @connection.on(:closed) do
          if @connected
            @deferred_status = nil
            @connected = false
            unless @closing_connection
              @reconnecting = true
              reconnect
            end
          else
            unless @closing_connection
              EM.add_timer(1) { reconnect }
            end
          end
        end

        @connection.on(:connected) do
          @connected = true
          succeed

          if @reconnecting
            @reconnecting = false
            emit(:reconnected)
          end
        end

        @connected = false
        @reconnecting = false

        return self
      end
    end

    def connected?
      @connected
    end

    def close_connection
      @closing_connection = true
      @connection.close_connection_after_writing
    end

    private

    def reconnect
      EventMachine::Kafka.logger.debug("Trying to reconnect to Kafka")
      @connection.reconnect @host, @port
    end
  end
end
