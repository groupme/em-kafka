module EventMachine
  module Kafka
    class Parser
      attr_accessor :offset

      def initialize(offset = 0, &block)
        self.offset = offset
        @block = block
        reset
      end

      def on_data(binary)
        if @complete
          parsed_size = binary[0, 4].unpack("N").shift

          if (parsed_size - 2) > 0
            @size = parsed_size
          else
            return
          end
        end

        @buffer << binary

        received_data = @buffer.size + binary.size
        if received_data >= @size
          parse if @buffer[0, @size]
        else
          @complete = false
        end
      end

      def on_complete(&callback)
        @on_complete_callback = callback
      end

      private

      def parse
        frame = @buffer[6..-1] # account for payload size and 2 byte offset
        i = 0

        while i <= frame.length do
          break unless message_size = frame[i, 4].unpack("N").first

          message_data = frame[i, message_size + 4]
          message = Kafka::Message.decode(message_size, message_data)
          @block.call(message)
          i += message_size + 4
        end

        self.offset += i
        complete
        reset
      end

      def reset
        @size = 0
        @complete = true
        @buffer = ""
      end

      def complete
        @on_complete_callback.call(offset) if @on_complete_callback
      end
    end
  end
end
