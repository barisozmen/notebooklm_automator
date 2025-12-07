require "thor"
require_relative "setup"
require_relative "ui"
require_relative "config"
require_relative "browser"
require_relative "pages/home_page"
require_relative "pages/notebook_page"

class NotebookLMCLI < Thor
  def initialize(*args)
    super
    @ui = UI.new
  end

  desc "create", "Create a new NotebookLM notebook with automated content generation"
  option :source, aliases: "-s", desc: "Source URL to add to the notebook", type: :string
  option :outputs, aliases: "-o", desc: "Output types (comma-separated: mindmap,flashcards,slides,interactive_chart)", type: :string
  option :debug, aliases: "-d", desc: "Enable debug output", type: :boolean, default: false
  def create
    @ui.blank_line
    @ui.header("NotebookLM Automator")
    @ui.blank_line

    collect_inputs
    show_summary
    run_automation
  end

  desc "config", "Show current configuration"
  def config
    @ui.blank_line
    @ui.header("Configuration")
    @ui.blank_line

    rows = [
      ["Chrome Profile", Config::CHROME_PROFILE],
      ["NotebookLM URL", Config::NOTEBOOKLM_URL],
      ["Source URL", Config.source_url || "(not set)"],
      ["Wait Time (s)", Config::WAIT_FOR_GENERATION],
      ["Output Types", Config.output_types.join(", ")]
    ]

    @ui.render_table(header: ["Setting", "Value"], rows: rows)
    @ui.blank_line
  end

  desc "version", "Show version"
  def version
    @ui.info("NotebookLM Automator v1.0.0")
  end

  private

  def collect_inputs
    Config.source_url = options[:source] || @ui.ask_source
    Config.setup_logger(debug: options[:debug])

    Config.output_types = if options[:outputs]
      options[:outputs].split(",").map(&:strip).map(&:to_sym)
    else
      Config::DEFAULT_OUTPUTS
    end
  end

  def show_summary
    @ui.blank_line
    @ui.divider
    @ui.info("Source: #{Config.source_url}")
    @ui.info("Outputs: #{Config.output_types.join(', ')}")
    @ui.divider
    @ui.blank_line
  end

  def run_automation
    ensure_chrome_running
    browser = @ui.with_spinner("Connecting to browser...") { Browser.instance }
    notebook_page = create_notebook(browser)
    print_notebook_url(notebook_page)
    add_source(notebook_page)
    generate_outputs(notebook_page)
    show_success(notebook_page)
  rescue StandardError => e
    @ui.blank_line
    if defined?(ErrorFormatter)
      puts ErrorFormatter.format(e)
    else
      @ui.error("Failed: #{e.message}")
      puts e.backtrace&.first(10)
    end
    @ui.blank_line
    raise
  end

  def ensure_chrome_running
    return if Browser.running?

    @ui.with_spinner("Starting Chrome...") do
      launch_script = File.join(__dir__, "bin", "launch_chrome.sh")
      Process.spawn(launch_script, out: "/dev/null", err: "/dev/null")

      Config::Timing::CHROME_STARTUP_RETRIES.times do
        break if Browser.running?
        sleep Config::Timing::RETRY_INTERVAL
      end

      raise "Chrome failed to start" unless Browser.running?
    end
  end

  def create_notebook(browser)
    @ui.with_spinner("Creating notebook...") do
      home = HomePage.new(browser)
      home.open  # Always navigate to home page first
      home.create_notebook
    end
  end

  def print_notebook_url(notebook_page)
    url = notebook_page.current_url
    url = "https://#{url}" unless url.start_with?("https://")
    @ui.blank_line
    @ui.url(url)
    @ui.blank_line
  end

  def add_source(notebook_page)
    @ui.with_spinner("Adding source...") do
      notebook_page.add_source(Config.source_url)
    end
  end

  def generate_outputs(notebook_page)
    @ui.step("Generating outputs...")
    Config.output_types.each do |type|
      @ui.with_spinner("Generating #{type}...") do
        notebook_page.click_generate(type)
        sleep Config::Timing::GENERATION_WAIT
      end
    end
  end

  def show_success(notebook_page)
    @ui.blank_line
    @ui.divider
    @ui.success("Notebook created successfully!")
    @ui.divider
    @ui.blank_line
  end

  def self.exit_on_failure?
    true
  end
end
