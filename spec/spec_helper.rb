# encoding: UTF-8
require "simplecov"
require "codeclimate-test-reporter"
require "stringio"

SimpleCov.formatter = SimpleCov::Formatter::MultiFormatter[
  SimpleCov::Formatter::HTMLFormatter,
  CodeClimate::TestReporter::Formatter
]

SimpleCov.start do
  minimum_coverage 100
end

require "bundler/setup"
Bundler.setup

require "stratocumulus"
Fog.mock!

RSpec.configure do |config|
  config.default_formatter = "doc" if config.files_to_run.one?

  config.profile_examples = 10
  config.order = :random
  Kernel.srand config.seed

  config.expect_with :rspec do |expectations|
    expectations.syntax = :expect
  end

  config.mock_with :rspec do |mocks|
    mocks.syntax = :expect
  end
end

def capture_stderr
  old_stderr = $stderr
  fake_stderr = StringIO.new
  $stderr = fake_stderr
  yield
  fake_stderr.string
ensure
  $stdout = old_stderr
end
