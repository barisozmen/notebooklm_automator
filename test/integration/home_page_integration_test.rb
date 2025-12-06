require_relative "../test_helper"

class HomePageIntegrationTest < Minitest::Test
  include TestHelpers

  def setup
    skip_unless_chrome_available
    @browser = Browser.instance
    @page = @browser.create_page
    @home_page = HomePage.new(@page)
  end

  def teardown
    @page&.close
  end

  def test_can_navigate_to_notebooklm
    @page.go_to(Config::NOTEBOOKLM_URL)
    sleep 2

    assert @page.current_url.include?("notebooklm.google.com"),
      "Should navigate to NotebookLM"
  end

  def test_page_detector_on_real_page
    @page.go_to(Config::NOTEBOOKLM_URL)
    sleep 2

    state = PageDetector.detect_page(@page)
    refute_equal PageDetector::PageState::UNKNOWN, state,
      "PageDetector should recognize NotebookLM page"
  end
end
