require_relative "base_page"
require_relative "../config"
require_relative "page_detector"

class HomePage < BasePage
  # Navigate to NotebookLM home page and handle sign-in if needed
  def open
    Config.logger.debug "Creating new tab..."
    @page = page.create_page

    Config.logger.debug "Navigating to NotebookLM..."
    page.go_to(Config::NOTEBOOKLM_URL)

    Config.logger.debug "Waiting for page to load..."
    # Don't use wait_for_network_idle - NotebookLM has persistent connections
    sleep 3

    Config.logger.debug "Checking if sign-in needed..."
    handle_sign_in_if_needed

    self
  end

  # Create a new notebook
  def create_notebook
    Config.logger.debug "Creating new notebook..."
    click_new_notebook
    NotebookPage.new(page)
  end

  private

  def click_new_notebook
    Config.logger.debug "Clicking 'Create new' button..."
    click_button_with_text("Create new")
    sleep 1
    Config.logger.debug "Notebook creation initiated"
  end

  def handle_sign_in_if_needed
    if needs_sign_in?
      puts "\n⚠️  Please sign in to Google in the browser window"
      puts "Press Enter after you've signed in and see the NotebookLM home page..."
      $stdin.gets
      sleep 2
    end
  end

  def needs_sign_in?
    Config.logger.debug "Current URL: #{page.current_url}"

    # Check if we're on a sign-in page first
    if page.current_url.include?("accounts.google.com")
      Config.logger.debug "On Google sign-in page"
      return true
    end

    # List all buttons on the page for debugging
    all_buttons = page.xpath("//button")
    Config.logger.debug "Found #{all_buttons.length} buttons on the page"
    all_buttons.first(10).each_with_index do |btn, i|
      text = btn.text.strip
      Config.logger.debug "  Button #{i + 1}: '#{text[0..50]}'" unless text.empty?
    end

    # Look for the "Create new" button
    create_button = page.xpath("//button[contains(., 'Create new')]")

    if create_button.empty?
      Config.logger.debug "'Create new' button not found - assuming sign-in needed"
    else
      Config.logger.debug "'Create new' button found - already signed in"
    end

    create_button.empty?
  end
end
