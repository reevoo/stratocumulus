# encoding: UTF-8
require "stratocumulus/database"

module Stratocumulus
  class PostgreSQL < Database
    def command
      command = ""
      command << %(PGPASSWORD="#{@password}" ) if @password
      command << "pg_dump "
      command << "-U#{username} "
      command << "-h#{host} " unless socket?
      command << "-p#{port} " unless socket?
      command << @name
    end

    def dependencies
      super + ["pg_dump"]
    end

    private

    def username
      @username || "postgres"
    end

    def host
      @host || "localhost"
    end

    def port
      @port || 5432
    end
  end
end
