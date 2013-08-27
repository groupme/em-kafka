require 'spec_helper'

describe EM::Kafka::ProducerRequest do
  describe "#encode" do
    it "binary encodes an empty request" do
      bytes = EM::Kafka::ProducerRequest.new("test", 0, []).encode
      bytes.length.should eql(20)
      bytes.should eql("\000\000\000\020\000\000\000\004test\000\000\000\000\000\000\000\000")
    end

    it "should binary encode a request with a message, using a specific wire format" do
      request = EM::Kafka::ProducerRequest.new("test", 3, EM::Kafka::Message.new("ale"))
      bytes = request.encode

      data_size  = bytes[0, 4].unpack("N").shift
      request_id = bytes[4, 2].unpack("n").shift
      topic_length = bytes[6, 2].unpack("n").shift
      topic = bytes[8, 4]
      partition = bytes[12, 4].unpack("N").shift
      messages_length = bytes[16, 4].unpack("N").shift
      messages = bytes[20, messages_length]

      bytes.length.should eql(32)
      data_size.should eql(28)
      request_id.should eql(0)
      topic_length.should eql(4)
      topic.should eql("test")
      partition.should eql(3)
      messages_length.should eql(12)
    end

    it "encodes ruby objects to JSON and inflates message" do
      message = EM::Kafka::Message.new(Oj.dump({key: "value"}, mode: :compat))
      request_with_message = EM::Kafka::ProducerRequest.new("test", 3, message)
      request_with_message.encode.size.should == 44

      request = EM::Kafka::ProducerRequest.new("test", 3, key: "value")
      request.encode.size.should == 44
    end
  end
end
