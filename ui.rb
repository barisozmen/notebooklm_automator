require "tty-prompt"
require "tty-spinner"
require "tty-table"
require "tty-box"
require "tty-command"
require "pastel"

class UI
  attr_reader :prompt, :spinner, :pastel, :command

  def initialize(out: $stdout, err: $stderr)
    @prompt  = TTY::Prompt.new
    @pastel  = Pastel.new
    @command = TTY::Command.new(printer: :null)
    @out     = out
    @err     = err
  end

  def header(text)
    box = TTY::Box.frame(
      width: [text.size + 8, 60].max,
      height: 3,
      align: :center,
      border: :thick,
      style: {
        border: {
          fg: :bright_cyan
        }
      }
    ) { pastel.decorate(text, :bold, :bright_cyan) }
    puts box
  end

  def info(text)
    puts pastel.decorate("ℹ️  #{text}", :cyan)
  end

  def info_box(text)
    puts TTY::Box.frame(
      width: [text.size + 20, 60].max,
      padding: 1,
      border: :thick,
      style: {
        border: {
          fg: :bright_blue
        }
      }
    ) { pastel.decorate(text, :bright_blue) }
  end

  def success(text)
    puts pastel.decorate("✅  #{text}", :green, :bold)
  end

  def error(text)
    puts pastel.decorate("✖️  #{text}", :red, :bold)
  end

  def warning(text)
    puts pastel.decorate("⚠️  #{text}", :yellow)
  end

  def step(text)
    puts pastel.decorate("→ #{text}", :bright_magenta)
  end

  def url(text)
    puts pastel.decorate("🔗 #{text}", :bright_blue, :underline)
  end

  def ask_source
    prompt.ask("📎 Source URL:", required: true) do |q|
      q.validate(/^https?:\/\/.+/, "Must be a valid HTTP(S) URL")
      q.modify :strip
    end
  end

  def select_output_types
    choices = [
      { name: "Mind Map", value: :mindmap },
      { name: "Flashcards", value: :flashcards },
      { name: "Slides", value: :slides },
      { name: "Interactive Chart", value: :interactive_chart }
    ]

    prompt.multi_select("📊 Select outputs to generate:", choices, per_page: 10, echo: false)
  end

  def confirm(question)
    prompt.yes?(question)
  end

  def with_spinner(message, delay: 0.08)
    spinner = TTY::Spinner.new(
      "[:spinner] #{message}",
      format: :dots,
      interval: delay,
      success_mark: pastel.green("✓"),
      error_mark: pastel.red("✗")
    )
    spinner.auto_spin
    result = nil
    begin
      result = yield spinner
      spinner.success
    rescue StandardError => e
      spinner.error
      raise
    end
    result
  end

  def render_table(header:, rows:)
    table = TTY::Table.new(header, rows)
    puts table.render(:unicode, multiline: true, padding: [0, 2, 0, 2])
  end

  def divider
    puts pastel.dim("─" * 60)
  end

  def blank_line
    puts
  end
end
