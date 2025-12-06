require_relative "../test_helper"

class BrowserIntegrationTest < Minitest::Test
  include TestHelpers

  def setup
    skip_unless_chrome_available
  end

  def test_browser_connects_to_chrome
    browser = Browser.instance
    refute_nil browser, "Browser should connect to Chrome"
    assert browser.targets.size >= 1, "Browser should have at least one target"
  end

  def test_can_create_new_page
    browser = Browser.instance
    page = browser.create_page
    refute_nil page, "Should be able to create a new page"
    page.close
  end

  def test_browser_singleton_returns_same_instance
    browser1 = Browser.instance
    browser2 = Browser.instance
    assert_same browser1, browser2, "Browser should return the same instance"
  end
end
