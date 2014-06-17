# encoding: UTF-8
require 'fog'
require 'stratocumulus/ext/io'

module Stratocumulus
  class Storage
    def initialize(options = {})
      @access_key_id = options.fetch('access_key_id')
      @secret_access_key = options.fetch('secret_access_key')
      @region = options['region']
      @bucket = options.fetch('bucket')
    end

    def upload(database)
      files.create(
        key: database.filename,
        body: database.dump,
        multipart_chunk_size: 104_857_600, # 100MB
        public: false
      )
    end

    private

    def connection
      Fog::Storage.new(
        provider: 'AWS',
        aws_access_key_id: @access_key_id,
        aws_secret_access_key: @secret_access_key,
        region: @region
      )
    end

    def files
      connection.directories.get(@bucket).files
    end
  end
end
