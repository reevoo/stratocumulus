# encoding: UTF-8
require 'stratocumulus/database/mysql'

module Stratocumulus
  class Database
    def initialize(options = {})
      @name = options['name']
      fail 'database name not specified' unless @name
      setup_backend(options)
      check_dependencies
    end

    def dump
      IO.popen("bash -c '#{pipefail} #{@backend.command} | gzip'")
    end

    def filename
      @filename ||= Time.now.utc.strftime("#{@name}/#{@name}.%Y%m%d%H%M.sql.gz")
    end

    private

    def pipefail
      'set -o pipefail;'
    end

    def check_dependencies
      dependencies.each do |cmd|
        fail "#{cmd} not available" unless system("which #{cmd} >/dev/null")
      end
    end

    def dependencies
      ['gzip'] + @backend.dependencies
    end

    def setup_backend(options)
      type = options['type']
      fail "#{type} is not a supported database" unless type == 'mysql'
      @backend = MySQL.new(options)
    end
  end
end
