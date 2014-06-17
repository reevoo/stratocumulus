# encoding: UTF-8

module Stratocumulus
  class Database
    def initialize(options = {})
      @username = options['username'] || 'root'
      @password = options['password']
      @name = options['name']

      @host = options['host'] || 'localhost'
      @port = options['port'] || 3306

      check_dependencies(options['type'])
    end

    def dump
      IO.popen("bash -c '#{pipefail} #{mysqldump_command} | gzip'")
    end

    def filename
      "#{@name}/#{@name}.#{Time.now.utc.strftime('%Y%m%d%H%M')}.sql.gz"
    end

    private

    def mysqldump_command
      command = 'mysqldump '
      command << '--single-transaction '
      command << "-u#{@username} "
      command << "-h#{@host} "
      command << "-P#{@port} "
      command << "-p#{@password} " if @password
      command << @name
    end

    def pipefail
      'set -o pipefail;'
    end

    def check_dependencies(type)
      fail 'database name not specified' unless @name
      fail "#{type} is not a supported database" unless type == 'mysql'
      fail 'mysqldump not available' unless system('which mysqldump >/dev/null')
      fail 'gzip not available' unless system('which gzip >/dev/null')
    end
  end
end
