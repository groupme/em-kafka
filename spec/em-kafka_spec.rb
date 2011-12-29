require "spec_helper"

describe EventMachine::Kafka do
  describe ".logger" do
    it "sets logger" do
      new_logger = Logger.new(STDOUT)
      EM::Kafka.logger = new_logger
      EM::Kafka.logger.should == new_logger
    end
  end
end
