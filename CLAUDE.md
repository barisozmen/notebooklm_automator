# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

NotebookLM Automator is a Ruby CLI tool that automates NotebookLM notebook creation using Playwright (via Ferrum) to control Chrome. It creates notebooks with mind maps, flashcards, slides, and interactive charts from YouTube or website URLs.

## Prerequisites & Setup

```bash
# Install dependencies
bundle install
npx playwright install chromium

# Launch Chrome with remote debugging (required before running automation)
./bin/launch_chrome.sh

# Sign in to Google/NotebookLM in the Chrome window, then keep it open
```

## Running the Tool

```bash
# Interactive mode (prompts for inputs)
bin/notebooklm create

# Command line mode
bin/notebooklm create \
  --source "https://www.youtube.com/watch?v=..." \
  --outputs "mindmap,flashcards,slides"

# Enable debug logging
bin/notebooklm create --debug

# Show configuration
bin/notebooklm config
```

## Architecture

### Design Patterns

**Page Object Pattern**: Each page (HomePage, NotebookPage) encapsulates page-specific actions and selectors. All page classes inherit from BasePage which provides shared element interaction methods.

**Singleton Browser**: `Browser.instance` maintains a single connection to Chrome running on port 9222 via Ferrum. The browser persists across the entire automation session.

**State Pattern**: `PageDetector` module identifies current page state (HOME, NOTEBOOK, ADD_SOURCE_MODAL, UNKNOWN) to enable intelligent navigation that works from any starting point.

**Strategy Pattern**: Source type detection (`youtube_url?` method) selects different strategies for YouTube vs Website sources.

### Key Components

- **cli.rb**: Thor CLI orchestration - handles command parsing, user interaction, and automation workflow
- **browser.rb**: Singleton that connects to Chrome via Ferrum on port 9222
- **config.rb**: Configuration constants and runtime state (source URL, output types, logger)
- **ui.rb**: Terminal UI helpers using TTY toolkit (spinners, tables, colored output)
- **pages/base_page.rb**: Shared element interaction methods (click_button_with_text, fill_input, wait_for_selector)
- **pages/home_page.rb**: Home page object that handles notebook creation
- **pages/notebook_page.rb**: Notebook page object that adds sources and generates outputs
- **pages/page_detector.rb**: State detection logic for smart navigation

### Navigation Flow

The automation does NOT assume starting from home page. It detects current state and adapts:

1. Navigate to NotebookLM URL
2. Detect page state (home, existing notebook, or modal already open)
3. Adapt based on state - reuse existing notebooks or create new ones
4. Ensure correct state before each action
5. Generate requested outputs

This makes the tool robust to different starting conditions.

### Source Type Detection

Source type is determined by URL pattern in `notebook_page.rb:67-69`:
- YouTube: URLs matching `youtube.com` or `youtu.be`
- Website: Everything else

To add new source types (e.g., PDF upload), extend the detection logic and add corresponding UI interaction methods.

### Output Types

Defined in `NotebookPage::OUTPUT_BUTTONS` (notebook_page.rb:6-11):
- `:mindmap` → "Mind Map"
- `:flashcards` → "Flashcards"
- `:slides` → "Slides"
- `:interactive_chart` → "Interactive Chart"

## Configuration

Edit `config.rb` to customize:
- `CHROME_PROFILE`: Chrome profile path (default: `~/.notebooklm_chrome_profile`)
- `NOTEBOOKLM_URL`: NotebookLM base URL
- `WAIT_FOR_GENERATION`: Seconds to wait after clicking generate (default: 15)
- `DEFAULT_OUTPUTS`: Default output types if not specified via CLI

## Code Style

This codebase follows Unix Philosophy and Single Responsibility Principle:
- Clean, focused, minimal abstractions
- No unnecessary helpers or utilities
- Each class has a single, well-defined purpose
- Avoid over-engineering - solve the current problem, not hypothetical future ones

## Debugging

Use `--debug` flag to enable detailed logging:
```bash
bin/notebooklm create --debug
```

Debug logs show:
- Page detection process
- Element searches and XPath queries
- Click and input actions
- State transitions

## Common Issues

**"Failed to connect to Chrome on port 9222"**:
- Run `./bin/launch_chrome.sh` first
- Ensure Chrome window stays open during automation
- Check that no other process is using port 9222

**Element not found errors**:
- NotebookLM UI may have changed - check selectors in page objects
- Use `--debug` to see what elements are being searched for
- Increase sleep times if timing issues occur

## Dependencies

- **ferrum**: Headless Chrome automation (Playwright/CDP wrapper)
- **thor**: CLI framework
- **tty-***: Beautiful terminal UI toolkit (prompts, spinners, tables, colors)
- **pastel**: Terminal color formatting

Development gems: pry, pry-rescue, amazing_print
