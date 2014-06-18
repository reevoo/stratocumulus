# encoding: UTF-8
require 'stratocumulus/database/mysql'
require 'English'

module Stratocumulus
  class Database
    def initialize(options = {}, backend_class = nil)
      @name = options['name']
      fail 'database name not specified' unless @name
      setup_backend(backend_class, options)
      check_dependencies
    end

    def dump
      @dump ||= IO.popen("bash -c '#{pipefail} #{@backend.command} | gzip'")
    end

    def success?
      dump.read
      dump.close
      $CHILD_STATUS.success?
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

    def setup_backend(backend_class, options)
      backend_class ||= MySQL
      type = options['type']
      fail "#{type} is not a supported database" unless type == 'mysql'
      @backend = backend_class.new(options)
    end
  end
end
