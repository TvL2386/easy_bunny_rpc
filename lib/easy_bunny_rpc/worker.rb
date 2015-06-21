require 'bunny'
require 'json'

module EasyBunnyRPC
  class Worker
    def initialize(options={})
      @options = options
    end

    private

    def subscribe
      queue.subscribe(block: true) do |delivery_info, properties, payload|
        @delivery_info, @properties, @payload = delivery_info, properties, payload

        yield JSON.parse(payload).first
      end
    end

    def publish(success, payload)
      obj = { 'success' => success, 'payload' => payload }.to_json

      exchange.publish(obj, routing_key: @properties.reply_to, correlation_id: @properties.correlation_id)
    end

    def publish_success(payload)
      publish true, payload
    end

    def publish_failure(payload)
      publish false, payload
    end

    def connection
      return @connection if defined?(@connection)

      @connection = Bunny.new(@options[:bunny])
      @connection.start
      @connection
    end

    def channel
      return @channel if defined?(@channel)

      @channel = connection.create_channel
      @channel.prefetch(1)
      @channel
    end

    def queue
      @queue ||= channel.queue(@options[:queue])
    end

    def exchange
      @exchange ||= channel.default_exchange
    end
  end
end