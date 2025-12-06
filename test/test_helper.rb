require "minitest/autorun"
require "minitest/reporters"

# Use a better test reporter
Minitest::Reporters.use! [
  Minitest::Reporters::SpecReporter.new(color: true)
]

# Add project root to load path
$LOAD_PATH.unshift File.expand_path("..", __dir__)

# Require project files
require_relative "../config"
require_relative "../browser"
require_relative "../ui"
require_relative "../pages/base_page"
require_relative "../pages/page_detector"
require_relative "../pages/home_page"
require_relative "../pages/notebook_page"

# Initialize logger for tests
Config.setup_logger(debug: false)

# Test helpers module
module TestHelpers
  # Helper to check if Chrome is running on port 9222
  def chrome_available?
    require "net/http"
    uri = URI("http://localhost:9222/json/version")
    response = Net::HTTP.get_response(uri)
    response.is_a?(Net::HTTPSuccess)
  rescue StandardError
    false
  end

  # Skip test if Chrome is not available
  def skip_unless_chrome_available
    skip "Chrome must be running on port 9222 (run ./bin/launch_chrome.sh)" unless chrome_available?
  end

  # Create a mock Ferrum browser element
  class MockElement
    attr_reader :text, :attributes

    def initialize(text: "", attributes: {})
      @text = text
      @attributes = attributes
    end

    def click
      true
    end

    def focus
      true
    end

    def type(*args)
      true
    end
  end

  # Create a mock Ferrum page
  class MockPage
    attr_accessor :url

    def initialize
      @url = "https://notebooklm.google.com"
      @elements = {}
    end

    def goto(url)
      @url = url
    end

    def at_xpath(xpath)
      @elements[xpath]
    end

    def at_css(selector)
      @elements[selector]
    end

    def add_element(selector, element)
      @elements[selector] = element
    end

    def screenshot(path:)
      true
    end
  end
end
