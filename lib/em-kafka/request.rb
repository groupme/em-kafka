module EventMachine
  module Kafka
    class Request
      def initialize(topic, partition, messages)
        @topic, @partition, @messages = topic, partition, messages
      end

      def encode
        data = "\x00\x00" +
               [@topic.length].pack("n") +
               @topic +
               [@partition].pack("N") +
               encode_messages(@messages)

        [data.length].pack("N") + data
      end

      private

      def encode_messages(messages)
        message_set = Array(messages).map { |m|
          data = m.encode
          [data.length].pack("N") + data
        }.join("")
        [message_set.length].pack("N") + message_set
      end
    end
  end
end
