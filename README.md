# distributed lock gem

The distributed lock gem uses redis to implement a semaphore.

# Usage

Add this line to your Gemfile
```ruby
gem 'distributed_lock', git: 'git@github.com:BookBub/distributed_lock.git'
```

Add an initializer
```ruby
DistributedLock.setup(redis_provider: <redis provider>, redis_topic_provider: <redis provider for topics>)
```

Each provider should have a `with` method that yields a redis client object from the redis gem.
It is up to the provider to determine redis connection pooling and the connection information.

To use the lock:
```ruby
DistributedLock.for("key") do
  puts "This is only executed once if two processes call it at the same time"
end
```