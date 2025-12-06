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

## Troubleshooting

**"Failed to connect to Chrome on port 9222"**
- Make sure you ran `./bin/launch_chrome.sh` first
- Keep the Chrome window open during automation

**Element not found errors**
- Use `--debug` flag to see detailed logs
- NotebookLM UI may have changed
