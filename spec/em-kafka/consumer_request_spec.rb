require 'spec_helper'

describe EM::Kafka::ConsumerRequest do
  before do
    @request = EM::Kafka::ConsumerRequest.new(
      EM::Kafka::REQUEST_FETCH,
      "topic",
      0,
      100,
      EM::Kafka::MESSAGE_MAX_SIZE
    )
  end

  describe "#encode" do
    it "returns binary" do
      data = [EM::Kafka::REQUEST_FETCH].pack("n") +
             ["topic".length].pack('n') +
             "topic" +
             [0].pack("N") +
             [100].pack("Q").reverse + # DIY 64bit big endian integer
             [EM::Kafka::MESSAGE_MAX_SIZE].pack("N")

      @request.encode.should == data
    end
  end

  describe "#encode_size" do
    it "returns packed 2 + 2 + @topic.length + 4 + 8 + 4" do
      @request.encode_size.should == "\x00\x00\x00\x19"
    end
  end
end
