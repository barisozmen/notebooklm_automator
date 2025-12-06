require "rake/testtask"

# Default task
task default: :test

# Test task configuration
Rake::TestTask.new(:test) do |t|
  t.libs << "test"
  t.libs << "."
  t.test_files = FileList["test/**/*_test.rb"]
  t.verbose = true
  t.warning = false
end

# Run only unit tests (no browser required)
Rake::TestTask.new(:test_unit) do |t|
  t.libs << "test"
  t.libs << "."
  t.test_files = FileList["test/unit/**/*_test.rb"]
  t.verbose = true
  t.warning = false
end

# Run integration tests (requires browser)
Rake::TestTask.new(:test_integration) do |t|
  t.libs << "test"
  t.libs << "."
  t.test_files = FileList["test/integration/**/*_test.rb"]
  t.verbose = true
  t.warning = false
end

desc "Show available rake tasks"
task :help do
  puts "Available tasks:"
  puts "  rake test            - Run all tests"
  puts "  rake test_unit       - Run unit tests only (no browser required)"
  puts "  rake test_integration - Run integration tests (requires Chrome on port 9222)"
end
