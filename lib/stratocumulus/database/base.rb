# encoding: UTF-8
require 'stratocumulus/database/pipe_io'
require 'English'

module Stratocumulus
  class Database
    class Base
      def initialize(options = {})
        check_dependencies
        @username = options['username']
        @password = options['password']
        @name = options['name']
        @host = options['host']
        @port = options['port']
      end

      def dump
        @dump ||= PipeIO.popen("bash -c '#{pipefail} #{command} | gzip'")
      end

      def filename
        @name + '/' + file
      end

      def success?
        dump.read
        dump.close
        $CHILD_STATUS.success?
      end

      def dependencies
        ['gzip']
      end

      private

      def check_dependencies
        dependencies.each do |cmd|
          fail "#{cmd} not available" unless system("which #{cmd} >/dev/null")
        end
      end

      def file
        @file ||= Time.now.utc.strftime("#{@name}.%Y%m%d%H%M#{suffix}")
      end

      def suffix
        '.sql.gz'
      end

      def pipefail
        'set -o pipefail;'
      end

      def socket?
        !@host && !@port
      end
    end
  end
end
