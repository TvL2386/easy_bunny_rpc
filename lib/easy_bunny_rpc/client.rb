require 'bunny'
require 'json'
require 'securerandom'

module EasyBunnyRPC
  class Client
    def initialize options={}
      @options = options
      @subscribed = false

      # The timed queue which will collect incoming messages
      @timed_queue = EasyBunnyRPC::TimedQueue.new

      # Need to set a default timeout. How about 5 seconds?
      set_timeout(5)
    end

    def pop
      correlation_id, payload = @timed_queue.pop_with_timeout(@timeout)

      JSON.parse(payload).merge!({ 'correlation_id' => correlation_id })
    end

    def set_timeout(value)
      @timeout = value
    end

    def publish(payload, correlation_id=default_correlation_id)
      start_subscription unless @subscribed
      exchange.publish([payload].to_json, routing_key: @options[:queue], correlation_id: correlation_id, reply_to: queue.name, expiration: (@timeout*1000).to_i)
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

      @subscribed = false
    end

    private

    def start_subscription
      queue.subscribe(block: false) do |delivery_info, properties, payload|
        @timed_queue.push([properties.correlation_id, payload])
      end

      @subscribed = true
    end

    def connection
      return @connection if defined?(@connection)

      @connection = Bunny.new(@options[:bunny])
      @connection.start
      @connection
    end

    def channel
      @channel ||= connection.create_channel
    end

    # The exclusive no-name queue that is created for communicating back to me
    def queue
      @queue ||= channel.queue(generate_queue_name, exclusive: true)
    end

    def generate_queue_name
      [@options[:queue], '-client_', SecureRandom.hex].join
    end

    def exchange
      @exchange ||= channel.default_exchange
    end

    def default_correlation_id
      ''
    end
  end
end