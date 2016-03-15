require 'spec_helper'

describe DistributedLock do

  before :each do
    redis_provider = Object.new
    def redis_provider.with
      yield Redis.new
    end
    DistributedLock.setup(redis_provider, redis_provider)
  end

  it "should yield when acquiring the lock" do
    yielded = false
    DistributedLock.for("test") do
      yielded = true
    end
    expect(yielded).to be(true)
  end

  it "should yield every time if there is no overlap" do
    yielded_a = false
    yielded_b = false
    DistributedLock.for("test") do
      yielded_a = true
    end
    DistributedLock.for("test") do
      yielded_b = true
    end
    expect(yielded_a).to be(true)
    expect(yielded_b).to be(true)
  end

  it "should not yield when the requests to acquire the lock overlap" do
    queue_a = Queue.new
    queue_b = Queue.new

    yielded_a = false
    yielded_b = false

    thread_a = Thread.new do
      DistributedLock.for("test", timeout_ms: 5000) do
        queue_a << "started"
        queue_b.pop
        yielded_a = true
      end
    end

    queue_a.pop

    expect(DistributedLock.new("test").locked?).to be(true)

    thread_b = Thread.new do
      DistributedLock.for("test", on_before_wait: lambda { queue_b << "started" }) do
        yielded_b = true
      end
    end

    thread_a.run
    while thread_b.status || thread_b.status
      thread_a.join(0.1)
      thread_b.join(0.1)
    end
    expect(yielded_a).to be(true)
    expect(yielded_b).to be(false)
  end

  it "should timeout a lock" do
    lock = DistributedLock.new("test", timeout_ms: 250)
    lock.lock
    expect(lock.locked?).to be(true)
    sleep(0.5)
    expect(lock.locked?).to be(false)
  end
end
