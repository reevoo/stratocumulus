# encoding: UTF-8
require "thor"

module Stratocumulus
  class Cli < Thor
    desc "backup CONFIG",
      "runs a stratocumulus backup as specified in the config file"
    def backup(config)
      Stratocumulus::Runner.new(config).run
    end
  end
end
