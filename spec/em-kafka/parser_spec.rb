require 'spec_helper'

describe EM::Kafka::Parser do

  let(:message_1) { EM::Kafka::Message.new("foo").encode }
  let(:message_2) { EM::Kafka::Message.new("barizzle").encode }
  let(:message_3) { EM::Kafka::Message.new("langlang").encode }
  let(:message_4) { EM::Kafka::Message.new("after empty").encode }
  let(:messages)  { [] }
  let(:parser)    { EM::Kafka::Parser.new do |batch| messages.concat(batch) end }

  let :binary_1 do
    [51].pack("N") +
      [0, 0].pack("CC") + # 2 byte offset
      [message_1.bytesize].pack("N") +
      message_1 +
      [message_2.bytesize].pack("N") +
      message_2 +
      [message_3.bytesize].pack("N") +
      message_3
  end

  let :binary_2 do
    [26].pack("N") +
      [0, 0].pack("CC") + # 2 byte offset
      [message_4.bytesize].pack("N") +
      message_4
  end

  describe "parse" do

    it "parses messages from newline boundaries across packets" do
      frame_1 = binary_1[0..11]
      frame_2 = binary_1[12..-1]

      parser.on_data(frame_1)
      parser.on_data(frame_2)

      messages.should have(3).items
      messages[0].payload.should == "foo"
      messages[0].should be_valid
      messages[1].payload.should == "barizzle"
      messages[1].should be_valid
      messages[2].payload.should == "langlang"
      messages[2].should be_valid
    end

    it "parses messages correctly across packets" do
      parser.on_data(binary_1[0..23])
      parser.on_data(binary_1[24..47])
      parser.on_data(binary_1[48..-1])
      messages.map(&:payload).should == ["foo", "barizzle", "langlang"]
    end

    it "skips empty frames" do
      parser.on_data(binary_1)
      empty_frame = [2, 0, 0].pack("NCC")
      parser.on_data(empty_frame)
      parser.on_data(binary_2)

      messages.should have(4).items
      messages[3].payload.should == "after empty"
      messages[3].should be_valid
    end

  end

  describe "on_offset_update" do

    it "returns the proper offset" do
      offset = 0
      parser.on_offset_update {|new_offset| offset = new_offset }

      frame_1 = binary_1[0..11]
      frame_2 = binary_1[12..-1]
      parser.on_data(frame_1)
      parser.on_data(frame_2)
      offset.should == message_1.bytesize + message_2.bytesize + message_3.bytesize + 4 + 4 + 4
    end
  end
end
