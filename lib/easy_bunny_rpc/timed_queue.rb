require 'thread'
require 'timeout'

module EasyBunnyRPC
  class TimedQueue
    def initialize
      @array = Array.new
      @mutex = Mutex.new
      @cv = ConditionVariable.new
    end

    def push(item)
      @mutex.synchronize do
        @array.push(item)
        @cv.signal
      end
    end

    def pop_with_timeout(timeout=0.5)
      timeout_at = Time.now + timeout

      @mutex.synchronize do
        loop do
          if @array.empty?
            remaining = timeout_at - Time.now

            raise(Timeout::Error, "Waited #{timeout} seconds to pop") if(remaining <= 0)

            @cv.wait(@mutex, remaining)
          else
            return @array.pop
          end
        end
      end
    end
  end
end
