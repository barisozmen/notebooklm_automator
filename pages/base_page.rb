class BasePage
  attr_reader :page

  def initialize(page)
    @page = page
  end

  # Helper method to wait for a selector to appear
  def wait_for_selector(selector, timeout: 10)
    start_time = Time.now
    loop do
      element = page.at_css(selector)
      return element if element

      if Time.now - start_time > timeout
        raise "Timeout waiting for selector: #{selector}"
      end

      sleep 0.1
    end
  end

  # Helper method to wait for a button with specific text to appear
  def wait_for_button(text, timeout: 10)
    start_time = Time.now
    loop do
      button = page.xpath("//button[contains(., '#{text}')]").first
      return button if button

      if Time.now - start_time > timeout
        raise "Timeout waiting for button with text: #{text}"
      end

      sleep 0.1
    end
  end

  # Helper to click an element by text content (buttons only)
  def click_button_with_text(text)
    # Try multiple XPath strategies to find the button
    strategies = [
      "//button[contains(normalize-space(.), '#{text}')]",  # Normalized whitespace, anywhere in button
      "//button[normalize-space(.)='#{text}']",              # Exact match with normalized whitespace
      "//button[contains(., '#{text}')]",                    # Original approach
      "//button//span[contains(., '#{text}')]/ancestor::button"  # Text in span within button
    ]

    strategies.each_with_index do |xpath, i|
      button = page.xpath(xpath).first
      if button
        button.click
        return
      end
    end

    raise "Could not find button with text: #{text}"
  end

  # Helper to click any clickable element by text (button, div, a, etc.)
  def click_element_with_text(text)
    # Try multiple selectors in order of preference
    selectors = [
      "//button[contains(., '#{text}')]",
      "//div[@role='button'][contains(., '#{text}')]",
      "//a[contains(., '#{text}')]",
      "//*[@role='button'][contains(., '#{text}')]",
      "//*[contains(@class, 'button')][contains(., '#{text}')]",
      "//*[contains(@class, 'clickable')][contains(., '#{text}')]"
    ]

    selectors.each do |selector|
      element = page.xpath(selector).first
      if element
        element.click
        return
      end
    end

    raise "Could not find clickable element with text: #{text}"
  end

  # Helper to fill input fields
  def fill_input(selector, text)
    input = page.at_css(selector)
    raise "Could not find input: #{selector}" unless input

    input.focus.type(text)
  end

  # Helper to fill input fields with wait and visibility check
  def fill_input_with_wait(selector, text, timeout: 5)
    start_time = Time.now
    input = nil

    loop do
      input = page.at_css(selector)
      # Check if element exists and is visible
      if input
        begin
          # Try to focus - this will fail if element is not visible/interactable
          input.focus
          break
        rescue
          # Element exists but not interactable yet, continue waiting
        end
      end

      if Time.now - start_time > timeout
        raise "Timeout waiting for visible input: #{selector}"
      end

      sleep 0.2
    end

    input.type(text)
  end

  # Helper to wait for network to be idle
  def wait_for_network_idle
    page.network.wait_for_idle
  end

  # Get current URL
  def current_url
    page.current_url
  end
end
