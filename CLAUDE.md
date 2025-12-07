# CLAUDE.md

NotebookLM Automator is a Ruby CLI that automates NotebookLM via Chrome DevTools Protocol. Creates notebooks with mind maps, flashcards, slides, and infographics from YouTube or website URLs.

## Setup

```bash
bundle install
./bin/launch_chrome.sh  # Sign in to Google, keep window open
```

## Usage

```bash
bin/notebooklm create                                    # Interactive
bin/notebooklm create -s "URL" -o "mindmap,flashcards"  # CLI
bin/notebooklm create --debug                            # Debug mode
```

## Architecture

**Page Object Pattern** - HomePage, NotebookPage inherit from BasePage
**Singleton Browser** - `Browser.instance` connects to port 9222
**State Detection** - `PageDetector` enables navigation from any state
**Strategy Pattern** - Source type detection (YouTube vs Website)

### Flow

1. Navigate to NotebookLM home
2. Create new notebook
3. Add source (YouTube or Website)
4. Generate outputs (mindmap, flashcards, slides, infographic)

### Files

- `cli.rb` - Thor CLI, workflow orchestration
- `browser.rb` - Ferrum singleton connecting to Chrome
- `config.rb` - Constants and runtime state
- `ui.rb` - TTY toolkit UI (spinners, tables, colors)
- `setup.rb` - Pry, AmazingPrint, ErrorFormatter
- `pages/base_page.rb` - Shared element interactions
- `pages/home_page.rb` - Notebook creation
- `pages/notebook_page.rb` - Source addition, output generation
- `pages/page_detector.rb` - State detection

### Output Types

`NotebookPage::OUTPUT_BUTTONS` (notebook_page.rb:6-11):
- `:mindmap` → "Mind Map"
- `:flashcards` → "Flashcards"
- `:slides` → "Slide Deck"
- `:interactive_chart` → "Infographic"

### Source Detection

`youtube_url?` method (notebook_page.rb:213):
- YouTube: `youtube.com` or `youtu.be`
- Website: everything else

## Testing

```bash
rake test              # All tests
rake test_unit         # Unit only (no browser)
rake test_integration  # Integration (requires Chrome on 9222)
```

**Unit tests** (`test/unit/`): Logic without browser
**Integration tests** (`test/integration/`): Real browser automation

## Configuration

`config.rb`:
- `CHROME_PROFILE` - `~/.notebooklm_chrome_profile`
- `NOTEBOOKLM_URL` - NotebookLM base URL
- `WAIT_FOR_GENERATION` - 15 seconds
- `DEFAULT_OUTPUTS` - All four output types

## Debugging

`--debug` shows:
- Page state detection
- XPath queries and element searches
- Click/input actions
- State transitions

## Common Issues

**Connection failed**: Run `./bin/launch_chrome.sh` first
**Element not found**: Use `--debug`, check selectors, increase sleep times

## Code Style

Unix Philosophy. Single Responsibility. No over-engineering. Solve the current problem.
