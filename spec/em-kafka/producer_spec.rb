require "spec_helper"

describe EM::Kafka::Producer do
  before do
    @client = mock("Client", :connect => true)
    EM::Kafka::Client.should_receive(:new).and_return(@client)
  end

  it "defaults to partition 0" do
    EM::Kafka::Producer.new(:topic => "test").partition.should == 0
  end

  it "should set a topic and partition on initialize" do
    producer = EM::Kafka::Producer.new(
      :host       => "localhost",
      :port       => 9092,
      :topic      => "testing",
      :partition  => 3
    )
    producer.host.should == "localhost"
    producer.port.should == 9092
    producer.topic.should == "testing"
    producer.partition.should == 3
  end

  it "should send messages" do
    producer = EM::Kafka::Producer.new(
      :topic      => "testing",
      :partition  => 3
    )
    message = EM::Kafka::Message.new("hello world")
    request = EM::Kafka::Request.new("testing", 3, message)

    @client.should_receive(:send_data).with(request.encode)

    producer.deliver(message)
  end
end
