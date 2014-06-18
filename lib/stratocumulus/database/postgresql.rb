# encoding: UTF-8

module Stratocumulus
  class Database
    class PostgreSQL
      def initialize(options = {})
        @username = options['username'] || 'postgres'
        @password = options['password']
        @name = options['name']
        @host = options['host']
        @port = options['port']
      end

      def command
        command = ''
        command << %Q(PGPASSWORD="#{@password}" ) if @password
        command << 'pg_dump '
        command << "-U#{@username} "
        command << "-h#{host} " unless socket?
        command << "-p#{port} " unless socket?
        command << @name
      end

      def dependencies
        ['pg_dump']
      end

      private

      def host
        @host || 'localhost'
      end

      def port
        @port || 5432
      end

      def socket?
        !@host && !@port
      end
    end
  end
end
