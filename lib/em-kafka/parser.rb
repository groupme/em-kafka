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
            # empty response
            return
          end
        end

        @buffer << binary

        received_data = @buffer.size + binary.size
        if received_data >= @size
          parse(@buffer[6, @size]) # account for 4 byte size and 2 byte junk
        else
          @complete = false
        end
      end

      def on_offset_update(&callback)
        @on_offset_update_callback = callback
      end

      private

      def parse(frame)
        i = 0
        while i <= frame.length do
          break unless message_size = frame[i, 4].unpack("N").first
          message_data = frame[i, message_size + 4]
          message = Kafka::Message.decode(message_size, message_data)
          i += message_size + 4
          @block.call(message)
        end

        advance_offset(i)
        reset
      end

      def reset
        @size = 0
        @complete = true
        @buffer = ""
      end

      def advance_offset(i)
        self.offset += i
        @on_offset_update_callback.call(offset) if @on_offset_update_callback
      end
    end
  end
end
