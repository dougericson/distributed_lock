class DistributedLock

  def self.setup(redis_provider, redis_topic_provider)
    @@redis_provider = redis_provider
    @@redis_topic_provider = redis_topic_provider
  end

  def initialize(name, options = {})
    @name = name
    @options = {
      on_before_wait: nil,
      timeout_ms: 500,
      poll_interval_ms: 50
    }.merge(options)
  end

  def self.for(name, options = {})
    DistributedLock.new(name, options).with_lock do
      yield
    end
  end

  def with_lock
    # try to acquire the lock, if successful yield, then release the lock and exit
    # if unable to acquire the lock wait for it to be released then exit
    if lock
      begin
        yield
      ensure
        unlock
      end
    else
      call_on_before_wait
      wait_for_lock
    end
  end

  def lock
    @@redis_provider.with do |redis|
      !redis.client.call([:set, lock_key, true, :nx, :px, timeout_ms]).nil?
    end
  end

  def locked?
    @@redis_provider.with do |redis|
      redis.get(lock_key) == "true"
    end
  end

  def unlock
    @@redis_provider.with do |redis|
      redis.del(lock_key)
    end
    notify_unlock
  end

  def wait_for_lock
    wait_thread = Thread.new do
      @@redis_topic_provider.with do |redis|
        begin
          redis.subscribe(topic) do |on|
            on.message do |channel, message|
              redis.unsubscribe if channel == topic && redis.subscribed?
            end
          end
        ensure
          redis.unsubscribe if redis.subscribed?
        end
      end
    end

    while wait_thread.status && locked?
      wait_thread.join(poll_interval_seconds)
    end
    wait_thread.kill
  end

  def locks_set
    "Lock::locks"
  end

  def lock_key
    "Lock::locks::#{@name}"
  end

  def notify_unlock
    @@redis_provider.with do |redis|
      redis.publish(topic, "unlocked")
    end
  end

  def topic
    "Lock::topic::#{@name}"
  end

  def self.redis_provider
    @@redis_provider
  end

  def self.redis_topic_provider
    @@redis_topic_provider
  end

  private
  def poll_interval_seconds
    interval = @options[:poll_interval_ms].to_i
    interval = 50 if interval == 0
    interval.to_f / 1000
  end

  def timeout_ms
    timeout = @options[:timeout_ms].to_i
    timeout = 500 if timeout == 0
    timeout
  end

  def call_on_before_wait
    @options[:on_before_wait].call unless @options[:on_before_wait].nil?
  end
end