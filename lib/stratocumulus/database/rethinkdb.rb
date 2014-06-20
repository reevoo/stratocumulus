# encoding: UTF-8
require 'stratocumulus/database/base'
require 'tmpdir'

module Stratocumulus
  class Database
    class RethinkDB < Base
      def dump
        @success = system(command)
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
end
