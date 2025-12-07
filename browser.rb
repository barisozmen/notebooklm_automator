require "ferrum"
require "socket"
require_relative "config"

class Browser
  class ChromeNotRunningError < StandardError; end

  def self.running?
    Socket.tcp("localhost", 9222, connect_timeout: Config::Timing::CONNECTION_TIMEOUT) { true }
  rescue Errno::ECONNREFUSED, Errno::ETIMEDOUT, SocketError
    false
  end

  def self.instance
    @instance ||= connect_to_chrome
  end

  def self.connect_to_chrome
    Ferrum::Browser.new(
      url: "http://localhost:9222",
      window_size: [1920, 1080],
      timeout: 60
    )
  rescue Ferrum::BrowserError, Errno::ECONNREFUSED => e
    raise ChromeNotRunningError, <<~ERROR

      Failed to connect to Chrome on port 9222.

      Please launch Chrome with remote debugging first:
        ./bin/launch_chrome.sh

      Then sign in to Google/NotebookLM in the Chrome window.
      After that, run this command again.

      Original error: #{e.message}
    ERROR
  end

  def self.close
    @instance&.quit
    @instance = nil
  end
end
