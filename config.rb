require "logger"
require_relative "output_type"

module Config
  # Static configuration
  CHROME_PROFILE = File.expand_path("~/.notebooklm_chrome_profile")
  NOTEBOOKLM_URL = "https://notebooklm.google.com/"

  # Timing constants (seconds)
  module Timing
    BUTTON_CLICK = 1
    PAGE_LOAD = 3
    MODAL_OPEN = 1
    MODAL_TRANSITION = 1.5
    SOURCE_PROCESSING = 10
    GENERATION_WAIT = 15
    AFTER_GENERATE = 2

    DEFAULT_TIMEOUT = 10
    SHORT_TIMEOUT = 5
    CONNECTION_TIMEOUT = 1

    CHROME_STARTUP_RETRIES = 20
    RETRY_INTERVAL = 0.5
    POLL_INTERVAL = 0.1
  end

  # Default output types
  DEFAULT_OUTPUTS = OutputType.all_keys

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
