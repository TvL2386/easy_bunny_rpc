require 'bunny'
require 'json'

module EasyBunnyRPC
  class Worker
    def initialize(options={})
      @options = options
    end

    def publish_success(payload)
      publish true, payload
    end

    def publish_failure(payload)
      publish false, payload
    end

    def subscribe
      queue.subscribe(block: true) do |delivery_info, properties, payload|
        @delivery_info, @properties, @payload = delivery_info, properties, payload

        yield JSON.parse(payload).first
      end
    end

    def close
      if defined?(@channel)
        channel.close
        remove_instance_variable :@channel
        remove_instance_variable :@queue
      end

      if defined?(@connection)
        connection.close
        remove_instance_variable :@connection
      end

      if defined?(@exchange)
        remove_instance_variable :@exchange
      end
    end

    private

    def publish(success, payload)
      obj = { 'success' => success, 'payload' => payload }.to_json

      exchange.publish(obj, routing_key: @properties.reply_to, correlation_id: @properties.correlation_id)
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