require_relative "base_page"
require_relative "../config"
require_relative "../output_type"
require_relative "../element_waiter"

class NotebookPage < BasePage
  def open_add_source_modal
    log "Opening add source panel..."
    click_button_with_text("Add sources")
    sleep Config::Timing::BUTTON_CLICK

    log "Clicking 'Upload a source'..."
    upload_button = wait_for_button("Upload a source", timeout: Config::Timing::SHORT_TIMEOUT)
    upload_button.click
    log "Waiting for source type options..."
    sleep Config::Timing::MODAL_TRANSITION
  end

  def add_source(url)
    url = normalize_url(url)
    open_add_source_modal
    select_source_type(url)
    fill_source_url(url)
    submit_source
    wait_for_source_processing
  end

  def click_generate(type)
    button_text = OutputType.button_label(type)
    log "Looking for generate button: #{button_text}"

    button = wait_for_generate_button(button_text)
    log "Clicking: #{button_text}"
    button.click
    sleep Config::Timing::AFTER_GENERATE
  end

  private

  def select_source_type(url)
    source_type = youtube_url?(url) ? "YouTube" : "Website"
    log "Source type: #{source_type}"
    click_span_or_parent(source_type)
    sleep Config::Timing::MODAL_OPEN
  end

  def fill_source_url(url)
    log "Filling URL: #{url}"
    fill_textarea_by_label("Paste", url)
  end

  def submit_source
    log "Submitting source..."
    click_button_with_text("Insert")
  end

  def wait_for_source_processing
    log "Waiting for source processing..."
    sleep Config::Timing::SOURCE_PROCESSING
  end

  def fill_textarea_by_label(label_text, text, timeout: Config::Timing::SHORT_TIMEOUT)
    xpaths = textarea_xpaths(label_text)

    textarea = ElementWaiter.wait_until(
      timeout: timeout,
      interval: 0.2,
      error_message: "Textarea not found for label: #{label_text}"
    ) do
      find_and_focus_textarea(xpaths)
    end

    textarea.type(text)
  end

  def textarea_xpaths(label_text)
    [
      "//mat-label[contains(., '#{label_text}')]/ancestor::mat-form-field//input",
      "//mat-label[contains(., '#{label_text}')]/ancestor::mat-form-field//textarea",
      "//mat-label[contains(., '#{label_text}')]/following::input[1]",
      "//mat-label[contains(., '#{label_text}')]/following::textarea[1]",
      "//input[contains(@formcontrolname, 'newUrl')]",
      "//textarea[contains(@formcontrolname, 'newUrl')]"
    ]
  end

  def find_and_focus_textarea(xpaths)
    xpaths.each do |xpath|
      element = page.xpath(xpath).first
      next unless element

      begin
        element.focus
        return element
      rescue
        next
      end
    end
    nil
  end

  def wait_for_generate_button(button_text, timeout: Config::Timing::DEFAULT_TIMEOUT)
    log "Waiting for button: #{button_text}"

    button = ElementWaiter.wait_until(
      timeout: timeout,
      interval: 0.5,
      error_message: "Generate button not found: #{button_text}"
    ) do
      find_enabled_button(button_text)
    end

    scroll_into_view(button)
    button
  end

  def find_enabled_button(text)
    button_xpaths(text).each do |xpath|
      buttons = page.xpath(xpath)
      button = buttons.find { |btn| !btn[:disabled] && !btn['aria-disabled'] }
      return button if button
    end
    nil
  end

  def button_xpaths(text)
    [
      "//button[contains(normalize-space(.), '#{text}')]",
      "//button[normalize-space(.)='#{text}']",
      "//button[contains(., '#{text}')]",
      "//button//span[contains(., '#{text}')]/ancestor::button"
    ]
  end

  def scroll_into_view(element)
    page.evaluate("arguments[0].scrollIntoView({block: 'center'})", element)
    sleep 0.3
  rescue
    # Scroll failed, continue anyway
  end

  def normalize_url(url)
    # Ensure URL starts with https://
    url = url.strip
    url.start_with?('http://') || url.start_with?('https://') ? url : "https://#{url}"
  end

  def youtube_url?(url)
    url.match?(/youtube\.com|youtu\.be/i)
  end

  # Click a span element or its parent by exact text match
  def click_span_or_parent(text)
    # Use XPath to find the span and select its parent in one query
    parent = page.xpath("//span[normalize-space(text())='#{text}']/parent::*").first

    if parent
      Config.logger.debug "Found span with text '#{text}', clicking parent <#{parent.tag_name}>"
      parent.click
    else
      # Fallback to the flexible search
      Config.logger.debug "No exact span match, trying flexible search..."
      click_element_with_text(text)
    end
  end
end
