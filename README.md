easy\_bunny\_rpc
=================
[![Gem Version](https://badge.fury.io/rb/easy_bunny_rpc.svg)](https://rubygems.org/gems/easy_bunny_rpc)

Generic RPC client/worker library handling data serialization built on top of bunny.

Example usage
-----

Create an EchoWorker class which simply echoes whatever is received:

``` ruby
class EchoWorker < EasyBunnyRPC::Worker
  def mediate
    subscribe do |payload|
      publish_success(payload) # Send a success message to the client
      # publish_failure(payload) # Send a failure message to the client
    end
  rescue Interrupt => _
    # close
  end
end
```

Now you can initialize it. Please note the :bunny key Hash is directly fed to Bunny.new:

``` ruby
options = {
  queue: 'echo',
  bunny: {
    user: 'user',
    password: 'secret',
    host: 'localhost'
  }
}

echo_worker = EchoWorker.new options
echo_worker.mediate
```


Create an EchoClient class:

``` ruby
class EchoClient < EasyBunnyRPC::Client
  def perform
    set_timeout(2) # timeout in seconds, default is 5
    
    # The first argument is the payload, the send argument is the correlation_id
    # The correlation_id is always send back as-is by the worker
    # This way you can correlate the replies with your requests
    publish('hi there', 'call 1')
    publish('hi there again', 'call 2')

    # Pop will raise a ::Timeout::Error when a timeout occurs and no message is received
    p pop 
    p pop
  end
end
```

Now you can initialize it:

``` ruby
options = {
  queue: 'echo',
  bunny: {
    user: 'user',
    password: 'secret',
    host: 'localhost'
  }
}

echo_client = EchoClient.new(options)
echo_client.perform
```

Output:
``` text
{"success"=>true, "payload"=>"Succesfully reloaded", "correlation_id"=>"call 1"}
{"success"=>true, "payload"=>"Succesfully reloaded", "correlation_id"=>"call 2"}
```


Notes
_____

- Tested with RabbitMQ
- Uses the expiration feature of RabbitMQ to expire messages sent by the client


Install
-------

```
$ gem install easy_bunny_rpc
```


Author
------

Tom van Leeuwen, [@tvl2386](https://twitter.com/tvl2386)