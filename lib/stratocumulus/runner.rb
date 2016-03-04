# encoding: UTF-8

module Stratocumulus
  class Runner
    def initialize(config_path)
      @config = YAML.load(File.read(config_path))
    end

    def run
      @config["databases"].each do |database_config|
        database = Database.build(database_config)
        upload(database, database_config["storage"])
      end
    end

    private

    def upload(database, storage_type)
      fail "#{storage_type} is not supported" unless storage_type == "s3"
      storage.upload(database)
    end

    def storage
      Storage.new(@config["s3"])
    end
  end
end
