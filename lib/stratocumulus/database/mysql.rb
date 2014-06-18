# encoding: UTF-8

module Stratocumulus
  class Database
    class MySQL
      def initialize(options = {})
        @username = options['username'] || 'root'
        @password = options['password']
        @name = options['name']

        @host = options['host']
        @port = options['port']
      end

      def command
        command = 'mysqldump '
        command << '--single-transaction '
        command << "-u#{@username} "
        command << "-h#{host} " unless socket?
        command << "-P#{port} " unless socket?
        command << "-p#{@password} " if @password
        command << @name
      end

      def dependencies
        ['mysqldump']
      end

      private

      def host
        @host || 'localhost'
      end

      def port
        @port || 3306
      end

      def socket?
        !@host && !@port
      end
    end
  end
end
