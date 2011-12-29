require "bundler/setup"
Bundler.require :default, :development

require 'em-kafka'

RSpec.configure do |config|
  config.before(:each) do
    EM::Kafka.logger = Logger.new("/dev/null")
  end
end
