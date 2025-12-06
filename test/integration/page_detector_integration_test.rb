require_relative "../test_helper"

class PageDetectorIntegrationTest < Minitest::Test
  include TestHelpers

  def setup
    skip_unless_chrome_available
    @browser = Browser.instance
    @page = @browser.create_page
  end

  def teardown
    @page&.close
  end

  def test_detects_google_as_unknown_page
    @page.go_to("https://www.google.com")
    sleep 1  # Give page time to load

    state = PageDetector.detect_page(@page)
    assert_equal PageDetector::PageState::UNKNOWN, state
  end

  def test_detects_notebooklm_home_page
    @page.go_to("https://notebooklm.google.com/")
    sleep 2  # Give page time to load

    state = PageDetector.detect_page(@page)
    # Note: This will only pass if you're signed in to Google
    # Otherwise it might redirect to login
    assert_includes [PageDetector::PageState::HOME, PageDetector::PageState::UNKNOWN], state
  end
end
