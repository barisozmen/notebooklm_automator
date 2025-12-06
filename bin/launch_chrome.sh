#!/bin/bash

echo "🚀 Launching Chrome with remote debugging..."
echo ""
echo "Steps:"
echo "1. Chrome will open with a dedicated profile"
echo "2. Sign in to Google/NotebookLM if needed"
echo "3. Keep this Chrome window open"
echo "4. Run your automation in a separate terminal"
echo ""

/Applications/Google\ Chrome.app/Contents/MacOS/Google\ Chrome \
  --remote-debugging-port=9222 \
  --user-data-dir="$HOME/.notebooklm_chrome_profile" \
  --no-first-run \
  --no-default-browser-check
