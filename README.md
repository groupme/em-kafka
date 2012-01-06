# EM-Kafka

EventMachine driver for [Kafka](http://incubator.apache.org/kafka/index.html).

## Producer

When using Ruby objects, the payload is encoded to JSON

    producer = EM::Kafka::Producer.new("kafka://topic@localhost:9092/0")
    producer.deliver(:foo => "bar") # payload is {foo:"bar"}

## Consumer

    consumer = EM::Kafka::Consumer.new("kafka://topic@localhost:9092/0")
    consumer.consume do |message|
      puts message.payload
    end    

## Messages

Messages are composed of:

* a payload
* a magic id (defaults to 0)

Change the magic id when the payload format changes:

    EM::Kafka::Message.new("payload", 2)
    
Pass messages when you want to be specific:

    message_1 = EM::Kafka::Message.new("payload_1", 2)
    message_2 = EM::Kafka::Message.new("payload_2", 2)
    producer.deliver([message_1, message_2])
  
    
## Credits

Heavily influenced by / borrowed from:

* kafka-rb (Alejandro Crosa)
* em-hiredis (Martyn Loughran)