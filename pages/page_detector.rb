require_relative "../config"

module PageDetector
  # Page states
  module PageState
    HOME = :home
    NOTEBOOK = :notebook
    ADD_SOURCE_MODAL = :add_source_modal
    UNKNOWN = :unknown
  end

  class << self
    def detect_page(page)
      Config.logger.debug "Detecting current page state..."

      current_url = page.current_url
      Config.logger.debug "Current URL: #{current_url}"

      # Check for Home Page
      if home_page?(page)
        Config.logger.debug "Detected: Home Page"
        return PageState::HOME
      end

      # Check for Add Source Modal (modal is open on notebook page)
      if add_source_modal?(page)
        Config.logger.debug "Detected: Add Source Modal"
        return PageState::ADD_SOURCE_MODAL
      end

      # Check for Notebook Page
      if notebook_page?(page)
        Config.logger.debug "Detected: Notebook Page"
        return PageState::NOTEBOOK
      end

      Config.logger.debug "Detected: Unknown Page"
      PageState::UNKNOWN
    end

    private

    def home_page?(page)
      page.current_url == "https://notebooklm.google.com/" &&
        !page.xpath("//button[contains(., 'Create new')]").empty?
    end

    def notebook_page?(page)
      # Notebook URLs follow pattern: https://notebooklm.google.com/notebook/...
      page.current_url.include?("/notebook/") ||
        !page.xpath("//*[contains(., 'Add sources')]").empty?
    end

    def add_source_modal?(page)
      # Modal is open if we can see source type buttons (YouTube, Website, etc.)
      !page.xpath("//button[contains(., 'YouTube')]").empty? ||
        !page.xpath("//button[contains(., 'Website')]").empty?
    end
  end
end
