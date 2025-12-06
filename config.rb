require "logger"

module Config
  # Static configuration
  CHROME_PROFILE = File.expand_path("~/.notebooklm_chrome_profile")
  NOTEBOOKLM_URL = "https://notebooklm.google.com/"
  WAIT_FOR_GENERATION = 15 # seconds

  # Default output types
  DEFAULT_OUTPUTS = %i[mindmap flashcards slides interactive_chart]

  # Runtime state (set by CLI)
  class << self
    attr_accessor :source_url, :output_types
    attr_reader :logger

    def output_types
      @output_types || DEFAULT_OUTPUTS
    end

    def setup_logger(debug: false)
      @logger = Logger.new($stdout)
      @logger.level = debug ? Logger::DEBUG : Logger::INFO
      @logger.formatter = proc do |severity, datetime, progname, msg|
        if severity == "DEBUG"
          "[DEBUG] #{msg}\n"
        else
          "#{msg}\n"
        end
      end
    end

    def logger
      @logger ||= setup_logger
    end
  end
end
