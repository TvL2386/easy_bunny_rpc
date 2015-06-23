easy\_bunny\_rpc
=================
[![Gem Version](https://badge.fury.io/rb/easy_bunny_rpc.svg)](https://rubygems.org/gems/easy_bunny_rpc)

Generic RPC client/worker library handling data serialization built on top of bunny.

Example usage
-------------

The worker. Please note the :bunny key Hash is directly fed to Bunny.new:

``` ruby
options = {
  queue: 'echo',
  bunny: {
    user: 'user',
    password: 'secret',
    host: 'localhost'
  }
}

worker = EasyBunnyRPC::Worker.new(options)
worker.subscribe do |payload|
  publish_success(payload) # Send a success message to the client
  # publish_failure(payload) # Send a failure message to the client
end
```


The client:

``` ruby
# initialization options
options = {
  queue: 'echo',
  bunny: {
    user: 'user',
    password: 'secret',
    host: 'localhost'
  }
}

client = EasyBunnyRPC::Client.new(options)

# timeout in seconds, default is 5
client.set_timeout(2)

# The first argument is the payload. The payload can be anything, just keep in
# mind it must be serializable to a String because .to_json is called on it
# 
# The second argument is the correlation_id.
# The correlation_id is always send back as-is by the worker.
# This way you can correlate the replies with your requests.
client.publish('hi there', 'call 1')
client.publish('hi there again', 'call 2')

# Pop will raise a ::Timeout::Error when a timeout occurs and no message is received
puts client.pop
puts client.pop

client.close
```

Output:
``` text
{"success"=>true, "payload"=>"hi there", "correlation_id"=>"call 1"}
{"success"=>true, "payload"=>"hi there again", "correlation_id"=>"call 2"}
```


Notes
-----

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