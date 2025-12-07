require_relative "base_page"
require_relative "../config"
require_relative "page_detector"

class HomePage < BasePage
  def open
    log "Creating new tab..."
    @page = page.create_page

    log "Navigating to NotebookLM..."
    page.go_to(Config::NOTEBOOKLM_URL)

    log "Waiting for page to load..."
    sleep Config::Timing::PAGE_LOAD

    log "Checking if sign-in needed..."
    handle_sign_in_if_needed

    self
  end

  def create_notebook
    log "Creating new notebook..."
    click_new_notebook
    NotebookPage.new(page)
  end

  private

  def click_new_notebook
    log "Clicking 'Create new' button..."
    click_button_with_text("Create new")
    sleep Config::Timing::BUTTON_CLICK
  end

  def handle_sign_in_if_needed
    if needs_sign_in?
      puts "\n⚠️  Please sign in to Google in the browser window"
      puts "Press Enter after you've signed in and see the NotebookLM home page..."
      $stdin.gets
      sleep Config::Timing::AFTER_GENERATE
    end
  end

  def needs_sign_in?
    log "Current URL: #{page.current_url}"

    return true if page.current_url.include?("accounts.google.com")

    create_button = page.xpath("//button[contains(., 'Create new')]")
    create_button.empty?
  end
end
