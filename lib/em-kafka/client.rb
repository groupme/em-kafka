module EventMachine
  module Kafka
    class Client
      def initialize(host, port)
        @host = host || 'localhost'
        @port = port || 9092
        @callback = nil
      end

      def send_data(data)
        connect if @connection.nil? || @connection.disconnected?
        @connection.send_data(data)
      end

      def on_data(&block)
        @callback = block
      end

      def connect
        @connection = EM.connect(@host, @port, EM::Kafka::Connection)
        @connection.on(:message) do |message|
          @callback.call(message) if @callback
        end
        @connection
      end

      def close_connection
        @connection.close_connection_after_writing
      end
    end
  end
end
