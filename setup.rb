# Setup and configure development tools
if ENV['RACK_ENV'] != 'production'
  begin
    require 'amazing_print'
    require 'pry'

    # Configure Pry to use amazing_print
    Pry.config.print = proc { |output, value| output.puts value.ai }

    # Make 'ap' available globally
    AmazingPrint.defaults = {
      indent: 2,
      index: false,
      ruby19_syntax: true
    }
  rescue LoadError
    # Gems not installed yet
  end
end

# Enhanced error formatting
module ErrorFormatter
  def self.format(error)
    return error.message unless defined?(Pastel)

    pastel = Pastel.new
    output = []

    output << pastel.red.bold("\n#{error.class}: #{error.message}")
    output << pastel.yellow("\nBacktrace:")

    error.backtrace&.first(10)&.each do |line|
      if line.include?(Dir.pwd)
        # Highlight lines from the current project
        output << pastel.cyan("  #{line}")
      else
        output << pastel.dim("  #{line}")
      end
    end

    output.join("\n")
  end
end
