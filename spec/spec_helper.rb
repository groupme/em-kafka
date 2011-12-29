require "bundler/setup"
Bundler.require :default, :development

RSpec.configure do |config|
  config.before(:each) do
    EM::Kafka.logger = Logger.new("/dev/null")
  end
end
