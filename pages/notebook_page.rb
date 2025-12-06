require_relative "base_page"
require_relative "../config"
require_relative "page_detector"

class NotebookPage < BasePage
  OUTPUT_BUTTONS = {
    mindmap: "Mind Map",
    flashcards: "Flashcards",
    slides: "Slide Deck",
    interactive_chart: "Infographic"
  }.freeze

  # Opens the add source modal
  def open_add_source_modal
    Config.logger.debug "Opening add source panel..."
    click_button_with_text("Add sources")
    sleep 1

    Config.logger.debug "Clicking 'Upload a source'..."
    # Wait for the button to be present and stable before clicking
    upload_button = wait_for_button("Upload a source", timeout: 5)
    upload_button.click
    Config.logger.debug "Waiting for source type options to appear..."
    sleep 1.5  # Give modal time to render source type options
  end

  # Adds a source to the notebook
  def add_source(url)
    # Ensure URL starts with https://
    url = normalize_url(url)

    # Ensure we're in the add source modal
    open_add_source_modal

    # Determine source type based on URL
    source_type = youtube_url?(url) ? "YouTube" : "Website"

    Config.logger.debug "Detected source type: #{source_type}"

    # Debug: List elements with exact text match
    if Config.logger.level == Logger::DEBUG
      # Look for exact text matches in spans (common in Angular/Material apps)
      exact_spans = page.xpath("//span[normalize-space(text())='#{source_type}']")
      Config.logger.debug "Found #{exact_spans.length} <span> elements with exact text '#{source_type}'"
      exact_spans.each_with_index do |elem, i|
        # Use XPath to get parent instead of .parent method (not available in Ferrum)
        parent = page.xpath("//span[normalize-space(text())='#{source_type}'][#{i + 1}]/parent::*").first
        if parent
          Config.logger.debug "  Span #{i + 1}: <#{parent.tag_name}> parent, classes: #{parent['class']}"
        end
      end
    end

    Config.logger.debug "Clicking '#{source_type}' element..."
    click_span_or_parent(source_type)

    # Wait for the URL input textarea to appear in the modal
    sleep 1

    Config.logger.debug "Filling URL: #{url}"
    # Find textarea associated with mat-label containing "Paste"
    # YouTube uses "Paste YouTube URL", Website uses "Paste URLs"
    fill_textarea_by_label("Paste", url)

    Config.logger.debug "Clicking 'Insert' to confirm source..."
    click_button_with_text("Insert")
    Config.logger.debug "Waiting for source to be processed and Studio section to load..."
    sleep 10  # Wait for source to be added and Studio section buttons to appear
    Config.logger.debug "Source added successfully"
  end

  # Generate an output (mindmap, flashcards, etc.)
  def click_generate(type)
    button_text = OUTPUT_BUTTONS.fetch(type) { raise "Unknown output type: #{type}" }
    Config.logger.debug "Looking for generate button: #{button_text}"

    # Wait for page to be stable and button to be available
    button = wait_for_generate_button(button_text)

    Config.logger.debug "Clicking generate button for: #{button_text}"
    button.click
    Config.logger.debug "Successfully clicked: #{button_text}"

    # Wait after clicking to let the page process the click
    sleep 2
  end

  private

  # Fill textarea by finding mat-label with specific text
  def fill_textarea_by_label(label_text, text, timeout: 5)
    start_time = Time.now
    textarea = nil

    loop do
      # Try multiple XPath strategies to find the input/textarea
      # YouTube uses <input>, Website uses <textarea>
      xpaths = [
        "//mat-label[contains(., '#{label_text}')]/ancestor::mat-form-field//input",
        "//mat-label[contains(., '#{label_text}')]/ancestor::mat-form-field//textarea",
        "//mat-label[contains(., '#{label_text}')]/following::input[1]",
        "//mat-label[contains(., '#{label_text}')]/following::textarea[1]",
        "//input[contains(@formcontrolname, 'newUrl')]",
        "//textarea[contains(@formcontrolname, 'newUrl')]"
      ]

      xpaths.each_with_index do |xpath, i|
        textarea = page.xpath(xpath).first
        next unless textarea

        begin
          Config.logger.debug "Found textarea using strategy #{i + 1} for label containing '#{label_text}'"
          textarea.focus
          textarea.type(text)
          return
        rescue => e
          Config.logger.debug "Textarea found but not interactable yet (strategy #{i + 1}): #{e.message}"
          textarea = nil
        end
      end

      if Time.now - start_time > timeout
        # Debug: show available elements
        if Config.logger.level == Logger::DEBUG
          labels = page.xpath("//mat-label")
          inputs = page.xpath("//input")
          textareas = page.xpath("//textarea")
          Config.logger.debug "Timeout finding input/textarea for label containing '#{label_text}'"
          Config.logger.debug "Found #{labels.length} mat-labels:"
          labels.each_with_index do |label, i|
            Config.logger.debug "  #{i + 1}. '#{label.text.strip}'"
          end
          Config.logger.debug "Found #{inputs.length} inputs:"
          inputs.first(5).each_with_index do |inp, i|
            placeholder = inp[:placeholder] || 'no placeholder'
            formcontrol = inp[:formcontrolname] || 'no formcontrolname'
            Config.logger.debug "  #{i + 1}. placeholder='#{placeholder}', formcontrolname='#{formcontrol}'"
          end
          Config.logger.debug "Found #{textareas.length} textareas:"
          textareas.each_with_index do |ta, i|
            placeholder = ta[:placeholder] || 'no placeholder'
            Config.logger.debug "  #{i + 1}. placeholder='#{placeholder}'"
          end
        end
        raise "Timeout waiting for input/textarea associated with label containing: #{label_text}"
      end

      sleep 0.2
    end
  end

  def wait_for_generate_button(button_text, timeout: 10)
    Config.logger.debug "Waiting for button with text: #{button_text}"
    start_time = Time.now
    button = nil

    loop do
      # Wait a bit for page to settle between checks
      sleep 0.5

      # Try to find the button using multiple strategies
      strategies = [
        "//button[contains(normalize-space(.), '#{button_text}')]",
        "//button[normalize-space(.)='#{button_text}']",
        "//button[contains(., '#{button_text}')]",
        "//button//span[contains(., '#{button_text}')]/ancestor::button"
      ]

      strategies.each do |xpath|
        found_buttons = page.xpath(xpath)
        next if found_buttons.empty?

        # Find the first button that is not disabled
        button = found_buttons.find { |btn| !btn[:disabled] && !btn['aria-disabled'] }
        break if button
      end

      if button
        Config.logger.debug "Found enabled button: #{button_text}"
        # Try to scroll it into view
        begin
          page.evaluate("arguments[0].scrollIntoView({block: 'center'})", button)
          sleep 0.3
        rescue
          # Scroll failed, but continue anyway
        end
        return button
      end

      if Time.now - start_time > timeout
        # Debug: show what buttons are available
        if Config.logger.level == Logger::DEBUG
          all_buttons = page.xpath("//button")
          Config.logger.debug "Timeout waiting for button '#{button_text}'. Found #{all_buttons.length} total buttons:"
          button_texts = all_buttons.map { |btn| btn.text.strip }.reject(&:empty?).uniq
          button_texts.each_with_index do |text, i|
            Config.logger.debug "  #{i + 1}. '#{text}'"
          end
        end
        raise "Timeout waiting for enabled button with text: #{button_text}"
      end

      Config.logger.debug "Button '#{button_text}' not found or disabled, retrying..."
    end
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
