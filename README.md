# EM-Kafka

EventMachine driver for [Kafka](http://incubator.apache.org/kafka/index.html).

## Producer

    producer = EM::Kafka::Producer.new(
      :host       => "localhost",
      :port       => 9092,
      :topic      => "example",
      :partition  => 1
    )
    message = EM::Kafka::Message.new("payload")
    producer.deliver(message)

## Consumer

You can also use a URL string to connect:

    consumer = EM::Kafka::Consumer.new(
      :url => "kafka://topic@localhost:9092/0"
    )
    consumer.consume do |message|
      puts message.payload
    end
    

## Messages

Messages are composed of:

* a payload
* a magic id (defaults to 0)

Change the magic id when the payload format changes:

    EM::Kafka::Message.new("payload", 2)
    
## Credits

Heavily influenced by / borrowed from:

* kafka-rb (Alejandro Crosa)
* em-hiredis (Martyn Loughran)