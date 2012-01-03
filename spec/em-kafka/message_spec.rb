require 'spec_helper'

describe EM::Kafka::Message do
  describe "#encode" do
    it "turns Message into data" do
      message = EM::Kafka::Message.new("ale")
      message.payload.should == "ale"
      message.checksum.should == 1120192889
      message.magic.should == 0

      message.encode.should == [0].pack("C") +
                               [1120192889].pack("N") +
                                "ale".force_encoding(Encoding::ASCII_8BIT)
    end
  end

  describe ".decode" do
    it "turns data into a Message" do
      data = [12].pack("N") +
             [0].pack("C") +
             [1120192889].pack("N") + "ale"

      message = EM::Kafka::Message.decode(data.size, data)
      message.should be_valid
      message.payload.should == "ale"
      message.checksum.should == 1120192889
      message.magic.should == 0
    end
  end
end
