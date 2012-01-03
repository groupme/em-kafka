module EventMachine
  module Kafka
    # 1 byte "magic" identifier to allow format changes
    # 4 byte CRC32 of the payload
    # N - 5 byte payload
    class Message
      require "zlib"
      attr_accessor :magic, :checksum, :payload, :size

      def initialize(payload, magic = 0, checksum = nil, size = nil)
        self.payload  = payload
        self.magic    = magic
        self.checksum = checksum || Zlib.crc32(payload)
      end

      def valid?
        checksum == Zlib.crc32(payload)
      end

      def encode
        [magic, checksum].pack("CN") +
        payload.to_s.force_encoding(Encoding::ASCII_8BIT)
      end

      def self.decode(size, binary)
        return unless binary
        magic    = binary[4].unpack("C").shift
        checksum = binary[5..9].unpack("N").shift
        payload  = binary[9..-1]
        new(payload, magic, checksum)
      end
    end
  end
end
