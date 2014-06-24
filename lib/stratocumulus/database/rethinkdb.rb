# encoding: UTF-8
require 'stratocumulus/database'
require 'tmpdir'

module Stratocumulus
  class RethinkDB < Database
    def dump
      `#{command}`
      @success = $CHILD_STATUS.success?
      File.open(path)
    end

    def command
      command = 'rethinkdb dump '
      command << "-c #{host}:#{port} " unless socket?
      command << "-f #{path} "
      command << "-e #{@name}"
    end

    def success?
      File.delete(path)
      @success
    end

    def dependencies
      ['rethinkdb-dump']
    end

    private

    def path
      Dir.tmpdir + '/' + file
    end

    def suffix
      '.tar.gz'
    end
  end
end
