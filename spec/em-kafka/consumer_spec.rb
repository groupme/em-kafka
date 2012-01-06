require 'spec_helper'

describe EM::Kafka::Consumer do
  before do
    @client = mock("Client", :connect => true)
    EM::Kafka::Client.should_receive(:new).and_return(@client)
  end

  it "should set a topic and partition on initialize" do
    consumer = EM::Kafka::Consumer.new("kafka://testing@localhost:9092/3")
    consumer.host.should == "localhost"
    consumer.port.should == 9092
    consumer.topic.should == "testing"
    consumer.partition.should == 3
  end

  it "should set default partition to 0" do
    consumer = EM::Kafka::Consumer.new("kafka://testing@localhost:9092")
    consumer.host.should == "localhost"
    consumer.port.should == 9092
    consumer.topic.should == "testing"
    consumer.partition.should == 0
  end
end
