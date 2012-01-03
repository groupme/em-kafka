module EventMachine
  module Kafka
    class ConsumerRequest
      def initialize(type, topic, partition, offset, max_size)
        @type, @topic, @partition, @offset, @max_size =
          type, topic, partition, offset, max_size
      end

      def encode_size
        [2 + 2 + @topic.length + 4 + 8 + 4].pack("N")
      end

      def encode
        [@type].pack("n") +
        [@topic.length].pack('n') +
        @topic +
        [@partition].pack("N") +
        [@offset].pack("Q").reverse + # DIY 64bit big endian integer
        [@max_size].pack("N")
      end
    end
  end
end
