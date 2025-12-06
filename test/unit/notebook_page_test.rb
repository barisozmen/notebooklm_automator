require_relative "../test_helper"

class NotebookPageTest < Minitest::Test
  include TestHelpers

  # Test private methods by calling them via send
  def setup
    @page = NotebookPage.new(MockPage.new)
  end

  def test_youtube_url_detection_with_standard_url
    result = @page.send(:youtube_url?, "https://www.youtube.com/watch?v=dQw4w9WgXcQ")
    assert result, "Should detect youtube.com as YouTube URL"
  end

  def test_youtube_url_detection_with_short_url
    result = @page.send(:youtube_url?, "https://youtu.be/dQw4w9WgXcQ")
    assert result, "Should detect youtu.be as YouTube URL"
  end

  def test_youtube_url_detection_case_insensitive
    result = @page.send(:youtube_url?, "https://www.YOUTUBE.com/watch?v=dQw4w9WgXcQ")
    assert result, "Should detect YouTube URL case-insensitively"
  end

  def test_website_url_detection
    result = @page.send(:youtube_url?, "https://example.com")
    refute result, "Should not detect regular website as YouTube URL"
  end

  def test_url_normalization_adds_https
    result = @page.send(:normalize_url, "example.com")
    assert_equal "https://example.com", result
  end

  def test_url_normalization_preserves_https
    result = @page.send(:normalize_url, "https://example.com")
    assert_equal "https://example.com", result
  end

  def test_url_normalization_preserves_http
    result = @page.send(:normalize_url, "http://example.com")
    assert_equal "http://example.com", result
  end

  def test_url_normalization_strips_whitespace
    result = @page.send(:normalize_url, "  example.com  ")
    assert_equal "https://example.com", result
  end

  def test_output_buttons_constants
    assert_equal "Mind Map", NotebookPage::OUTPUT_BUTTONS[:mindmap]
    assert_equal "Flashcards", NotebookPage::OUTPUT_BUTTONS[:flashcards]
    assert_equal "Slide Deck", NotebookPage::OUTPUT_BUTTONS[:slides]
    assert_equal "Infographic", NotebookPage::OUTPUT_BUTTONS[:interactive_chart]
  end

  def test_click_generate_with_valid_type
    # Mock the wait_for_generate_button method
    mock_button = MockElement.new(text: "Mind Map")
    @page.stub :wait_for_generate_button, mock_button do
      @page.click_generate(:mindmap)
    end
  end

  def test_click_generate_with_invalid_type_raises
    error = assert_raises(RuntimeError) do
      @page.click_generate(:invalid_type)
    end
    assert_match /Unknown output type/, error.message
  end

  # Mock Page class
  class MockPage
    attr_accessor :url

    def initialize
      @url = "https://notebooklm.google.com/notebook/test"
    end

    def current_url
      @url
    end

    def xpath(path)
      []
    end

    def evaluate(script, *args)
      true
    end
  end
end
