# encoding: UTF-8
require 'stratocumulus/database/mysql'
require 'stratocumulus/database/postgresql'
require 'stratocumulus/database/rethinkdb'

module Stratocumulus
  class Database
    def initialize(options = {}, backend_class = nil)
      @name = options['name']
      fail 'database name not specified' unless @name
      setup_backend(backend_class, options)
    end

    def dump
      @backend.dump
    end

    def filename
      @backend.filename
    end

    def success?
      @backend.success?
    end

    private

    def setup_backend(backend_class, options)
      backend_class ||= backends[options['type']]
      fail "#{options['type']} is not a supported database" unless backend_class
      @backend = backend_class.new(options)
    end

    def backends
      {
        'psql' => PostgreSQL,
        'mysql' => MySQL,
        'rethinkdb' => RethinkDB
      }
    end
  end
end
