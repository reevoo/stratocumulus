# encoding: UTF-8
require "stratocumulus/database"
require "tmpdir"
require "fileutils"

module Stratocumulus
  class ETCD < Database
    def initialize(options = {})
      @data_dir = options["data_dir"]
    end

    def command
      command = "etcdctl "
      command << "backup "
      command << "--data-dir #{data_dir} "
      command << "--backup-dir #{backup_dir} "
      command << "&& tar -cf - -C #{backup_dir} . "
    end

    def dependencies
      super + ["etcdctl", "tar"]
    end

    def cleanup
      FileUtils.rm_rf(backup_dir)
      @_backup_dir = nil
    end

    private

    def suffix
      ".tar.gz"
    end

    def data_dir
      @data_dir || "/var/lib/etcd"
    end

    def backup_dir
      @_backup_dir ||= Dir.tmpdir
    end
  end
end
