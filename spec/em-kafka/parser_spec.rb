require 'spec_helper'

describe EM::Kafka::Parser do
  describe "parse" do
    it "parses messages from newline boundaries across packets" do
      messages = []
      parser = EM::Kafka::Parser.new do |message|
        messages << message
      end

      message_1 = EM::Kafka::Message.new("foo").encode
      message_2 = EM::Kafka::Message.new("barizzle").encode
      message_3 = EM::Kafka::Message.new("langlang").encode

      binary = [51].pack("N") +
               [0, 0].pack("CC") + # 2 byte offset
               [message_1.size].pack("N") +
               message_1 +
               [message_2.size].pack("N") +
               message_2 +
               [message_3.size].pack("N") +
               message_3

      frame_1 = binary[0..11]
      frame_2 = binary[12..-1]

      parser.on_data(frame_1)
      parser.on_data(frame_2)

      messages[0].payload.should == "foo"
      messages[0].should be_valid
      messages[1].payload.should == "barizzle"
      messages[1].should be_valid
      messages[2].payload.should == "langlang"
      messages[2].should be_valid

      empty_frame = [2, 0, 0].pack("NCC")
      parser.on_data(empty_frame)

      message_4 = EM::Kafka::Message.new("after empty").encode

      binary = [26].pack("N") +
               [0, 0].pack("CC") + # 2 byte offset
               [message_4.size].pack("N") +
               message_4

      frame_3 = binary
      parser.on_data(frame_3)

      messages[3].payload.should == "after empty"
      messages[3].should be_valid
    end
  end

  describe "on_offset_update" do
    it "returns the proper offset" do
      offset = 0
      messages = []
      parser = EM::Kafka::Parser.new do |message|
        messages << message
      end
      parser.on_offset_update {|new_offset| offset = new_offset }

      message_1 = EM::Kafka::Message.new("foo").encode
      message_2 = EM::Kafka::Message.new("barizzle").encode
      message_3 = EM::Kafka::Message.new("langlang").encode

      binary = [51].pack("N") +
               [0, 0].pack("CC") + # 2 byte offset
               [message_1.size].pack("N") +
               message_1 +
               [message_2.size].pack("N") +
               message_2 +
               [message_3.size].pack("N") +
               message_3

      frame_1 = binary[0..11]
      frame_2 = binary[12..-1]

      parser.on_data(frame_1)
      parser.on_data(frame_2)

      offset.should == message_1.size + message_2.size + message_3.size + 4 + 4 + 4
    end
  end
end
