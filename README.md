# NotebookLM Automator

A Ruby CLI tool that automates NotebookLM notebook creation using browser automation. Creates notebooks with mind maps, flashcards, slides, and interactive charts from YouTube or website URLs.

## Prerequisites

- Ruby 3.x
- Chrome browser
- Bundler

## Setup

```bash
# Install dependencies
bundle install
npx playwright install chromium

# Launch Chrome with remote debugging
./bin/launch_chrome.sh

# Sign in to Google/NotebookLM in the Chrome window, then keep it open
```

## Usage

```bash
# Interactive mode
bin/notebooklm create

# Command line mode
bin/notebooklm create \
  --source "https://www.youtube.com/watch?v=..." \
  --outputs "mindmap,flashcards,slides"

# Enable debug logging
bin/notebooklm create --debug
```

## Available Outputs

- `mindmap` - Mind Map
- `flashcards` - Flashcards
- `slides` - Slides
- `interactive_chart` - Interactive Chart

## How It Works

1. Connects to a running Chrome instance on port 9222
2. Navigates to NotebookLM
3. Creates a notebook and adds your source URL
4. Generates the requested outputs

## Testing

The project includes both unit tests and integration tests.

### Running Tests

```bash
# Install test dependencies first
bundle install

# Run all tests (unit + integration)
rake test

# Run only unit tests (no browser required)
rake test_unit

# Run only integration tests (requires Chrome on port 9222)
./bin/launch_chrome.sh  # In a separate terminal
rake test_integration
```

### Test Structure

- **Unit tests** (`test/unit/`): Test logic without browser interaction
  - `page_detector_test.rb`: Tests page state detection logic
  - `notebook_page_test.rb`: Tests URL detection and normalization

- **Integration tests** (`test/integration/`): Test actual browser automation
  - `browser_test.rb`: Tests browser connection and singleton pattern
  - `page_detector_integration_test.rb`: Tests page detection with real pages
  - `home_page_integration_test.rb`: Tests HomePage navigation

### Writing Tests

Tests use Minitest framework. Example:

```ruby
require_relative "../test_helper"

class MyTest < Minitest::Test
  include TestHelpers

  def test_something
    assert_equal expected, actual
  end
end
```

For integration tests that require a browser, use `skip_unless_chrome_available` in setup:

```ruby
def setup
  skip_unless_chrome_available
  @browser = Browser.instance
  @page = @browser.create_page
end
```

## Troubleshooting

**"Failed to connect to Chrome on port 9222"**
- Make sure you ran `./bin/launch_chrome.sh` first
- Keep the Chrome window open during automation

**Element not found errors**
- Use `--debug` flag to see detailed logs
- NotebookLM UI may have changed
