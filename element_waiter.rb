# Generic element waiting with timeout
class ElementWaiter
  class TimeoutError < StandardError; end

  def self.wait_until(timeout: 10, interval: 0.1, error_message: "Timeout waiting for condition")
    start_time = Time.now

    loop do
      result = yield
      return result if result

      if Time.now - start_time > timeout
        raise TimeoutError, "#{error_message} (waited #{timeout}s)"
      end

      sleep interval
    end
  end
end
