# encoding: UTF-8
require 'fog'
require 'logger'

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
      file = store_file(database)
      if database.success?
        add_expiry_rule(database.filename)
      else
        log.error("there was an error generating #{database.filename}")
        file.destroy
      end
    end

    private

    def store_file(database)
      files.create(
        key: database.filename,
        body: database.dump,
        multipart_chunk_size: 104_857_600, # 100MB
        public: false
      )
    end

    def connection
      Fog::Storage.new(
        provider: 'AWS',
        aws_access_key_id: @access_key_id,
        aws_secret_access_key: @secret_access_key,
        region: @region
      )
    end

    def files
      @files ||= directories.get(@bucket).files
    end

    def directories
      connection.directories
    end

    def add_expiry_rule(key)
      new_rule = @retention.rule(key)
      return unless new_rule
      directories.service.put_bucket_lifecycle(
        @bucket,
        'Rules' => current_rules << new_rule
      )
    end

    def current_rules
      existing_rules.select do |rule|
        files.find { |file| file.key == rule['ID'] }
      end
    end

    def existing_rules
      directories.service.get_bucket_lifecycle(@bucket).data[:body]['Rules']
    rescue Excon::Errors::NotFound
      []
    end

    def log
      Logger.new(STDERR)
    end
  end
end
