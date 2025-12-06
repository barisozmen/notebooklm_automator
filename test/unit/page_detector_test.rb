require_relative "../test_helper"

class PageDetectorTest < Minitest::Test
  include TestHelpers

  def test_detects_home_page
    page = MockPage.new
    page.url = "https://notebooklm.google.com/"
    page.add_element("//button[contains(., 'Create new')]", MockElement.new(text: "Create new"))

    state = PageDetector.detect_page(page)
    assert_equal PageDetector::PageState::HOME, state
  end

  def test_detects_notebook_page_by_url
    page = MockPage.new
    page.url = "https://notebooklm.google.com/notebook/abc123"

    state = PageDetector.detect_page(page)
    assert_equal PageDetector::PageState::NOTEBOOK, state
  end

  def test_detects_notebook_page_by_add_sources_element
    page = MockPage.new
    page.add_element("//*[contains(., 'Add sources')]", MockElement.new(text: "Add sources"))

    state = PageDetector.detect_page(page)
    assert_equal PageDetector::PageState::NOTEBOOK, state
  end

  def test_detects_add_source_modal_with_youtube_button
    page = MockPage.new
    page.add_element("//button[contains(., 'YouTube')]", MockElement.new(text: "YouTube"))

    state = PageDetector.detect_page(page)
    assert_equal PageDetector::PageState::ADD_SOURCE_MODAL, state
  end

  def test_detects_add_source_modal_with_website_button
    page = MockPage.new
    page.add_element("//button[contains(., 'Website')]", MockElement.new(text: "Website"))

    state = PageDetector.detect_page(page)
    assert_equal PageDetector::PageState::ADD_SOURCE_MODAL, state
  end

  def test_detects_unknown_page
    page = MockPage.new
    page.url = "https://google.com"

    state = PageDetector.detect_page(page)
    assert_equal PageDetector::PageState::UNKNOWN, state
  end

  # Mock Page class that implements necessary Ferrum methods
  class MockPage
    attr_accessor :url

    def initialize
      @url = "https://notebooklm.google.com"
      @elements = Hash.new { |h, k| h[k] = [] }
    end

    def current_url
      @url
    end

    def xpath(path)
      @elements[path] || []
    end

    def add_element(path, element)
      @elements[path] = [element]
    end
  end
end
