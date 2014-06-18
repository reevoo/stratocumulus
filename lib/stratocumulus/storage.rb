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
      @retention = Retention.new(options['retention'])
    end

    def upload(database)
      return unless @retention.upload_today?
      add_expiry_rule(database.filename)
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
      directories.get(@bucket).files
    end

    def directories
      connection.directories
    end

    def add_expiry_rule(key)
      new_rule = @retention.rule(key)
      return unless new_rule
      directories.service.put_bucket_lifecycle(
        @bucket,
        'Rules' => existing_bucket_lifecycle_rules << new_rule
      )
    end

    def existing_bucket_lifecycle_rules
      directories.service.get_bucket_lifecycle(@bucket).data[:body]['Rules']
    rescue Excon::Errors::NotFound
      []
    end
  end
end
