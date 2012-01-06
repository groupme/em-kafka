module EventMachine
  module Kafka
    class ProducerRequest
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
        messages = [messages].flatten
        messages = messages.map do |m|
          if m.is_a?(EM::Kafka::Message)
            m
          else
            EM::Kafka::Message.new(Yajl::Encoder.encode(m))
          end
        end

        message_set = messages.map { |m|
          data = m.encode
          [data.length].pack("N") + data
        }.join("")
        [message_set.length].pack("N") + message_set
      end
    end
  end
end
