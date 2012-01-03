module EventMachine
  module Kafka
    class Client
      include EventMachine::Kafka::EventEmitter
      include EM::Deferrable

      def initialize(host, port)
        @host = host || 'localhost'
        @port = port || 9092
        @closing_connection = false
        @callback = nil
      end

      def send_data(data)
        @connection.send_data(data)
      end

      def on_data(&block)
        @callback = block
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

        @connection.on(:message) do |message|
          @callback.call(message)
        end

        @connected = false
        @reconnecting = false

        return self
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
end
