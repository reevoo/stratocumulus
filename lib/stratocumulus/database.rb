# encoding: UTF-8
require "stratocumulus/database/pipe_io"
require "stratocumulus/database/mysql"
require "stratocumulus/database/postgresql"
require "stratocumulus/database/rethinkdb"
require "English"

module Stratocumulus
  class Database
    def self.build(options = {})
      backend_class = backends[options["type"]]
      fail "#{options["type"]} is not a supported database" unless backend_class
      backend_class.new(options)
    end

    def self.backends
      {
        "psql" => PostgreSQL,
        "mysql" => MySQL,
        "rethinkdb" => RethinkDB,
      }
    end

    def initialize(options = {})
      check_dependencies
      @username = options["username"]
      @password = options["password"]
      @name = options["name"]
      fail "database name not specified" unless @name
      @host = options["host"]
      @port = options["port"]
    end

    def dump
      @dump ||= PipeIO.popen("bash -c '#{pipefail} #{command} | gzip'")
    end

    def filename
      @name + "/" + file
    end

    def success?
      dump.read
      dump.close
      $CHILD_STATUS.success?
    end

    def dependencies
      ["gzip"]
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
      ".sql.gz"
    end

    def pipefail
      "set -o pipefail;"
    end

    def socket?
      !@host && !@port
    end
  end
end
