require_relative "../element_waiter"
require_relative "../config"

class BasePage
  attr_reader :page

  def initialize(page)
    @page = page
  end

  def log(message)
    Config.logger.debug(message)
  end

  def wait_for_selector(selector, timeout: Config::Timing::DEFAULT_TIMEOUT)
    ElementWaiter.wait_until(
      timeout: timeout,
      interval: Config::Timing::POLL_INTERVAL,
      error_message: "Selector not found: #{selector}"
    ) { page.at_css(selector) }
  end

  def wait_for_button(text, timeout: Config::Timing::DEFAULT_TIMEOUT)
    ElementWaiter.wait_until(
      timeout: timeout,
      interval: Config::Timing::POLL_INTERVAL,
      error_message: "Button not found: #{text}"
    ) { page.xpath("//button[contains(., '#{text}')]").first }
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

  def fill_input_with_wait(selector, text, timeout: Config::Timing::SHORT_TIMEOUT)
    input = ElementWaiter.wait_until(
      timeout: timeout,
      interval: 0.2,
      error_message: "Input not interactable: #{selector}"
    ) do
      element = page.at_css(selector)
      element if element && element.focus rescue nil
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
