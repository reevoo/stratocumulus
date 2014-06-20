# encoding: UTF-8
require 'stratocumulus/database/base'

module Stratocumulus
  class Database
    class MySQL < Base
      def command
        command = 'mysqldump '
        command << '--single-transaction '
        command << "-u#{username} "
        command << "-h#{host} " unless socket?
        command << "-P#{port} " unless socket?
        command << "-p#{@password} " if @password
        command << @name
      end

      def dependencies
        super + ['mysqldump']
      end

      private

      def username
        @username || 'root'
      end

      def host
        @host || 'localhost'
      end

      def port
        @port || 3306
      end
    end
  end
end
