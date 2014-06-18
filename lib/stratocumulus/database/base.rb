# encoding: UTF-8

module Stratocumulus
  class Database
    class Base
      def initialize(options = {})
        @username = options['username']
        @password = options['password']
        @name = options['name']
        @host = options['host']
        @port = options['port']
      end

      private

      def socket?
        !@host && !@port
      end
    end
  end
end
