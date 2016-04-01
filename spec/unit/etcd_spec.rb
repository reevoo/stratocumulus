# encoding: UTF-8
require "spec_helper"

describe Stratocumulus::ETCD do
  subject do
    described_class.new(config)
  end

  let(:config) do
    { "name" => "etcd_test" }
  end

  describe "#dependencies" do
    specify do
      expect(subject.dependencies).to eq %w(gzip etcdctl tar)
    end
  end

  describe "#command" do
    context "default" do
      it "generates the dump command with sensible defaults" do
        match = %r{etcdctl backup --data-dir /var/lib/etcd --backup-dir (.*) && tar -cf - -C (.*) \.}.match(subject.command)
        # We expect the backup dir passed to etcd to be the same as the one we pass to tar
        expect(match).to be_truthy
        expect(match[1]).to eq(match[2])
      end
    end

    context "when the datadir is set" do
      let(:config) do
        {
          "data_dir" => "/bar/foo/etcd",
          "name"     => "etcd_test"
        }
      end

      it "uses the given data dir" do
        expect(subject.command).to include "/bar/foo/etcd"
        expect(subject.command).to_not include "/var/lib/etcd"
      end
    end
  end

  describe "filename" do
    it "uses the correct suffix" do
      expect(subject.filename).to match(/.*\.tar\.gz$/)
    end
  end

  describe "#cleanup" do
    it "removes the backup dir" do
      match = %r{etcdctl backup --data-dir /var/lib/etcd --backup-dir (.*) && tar -cf - -C (.*) \.}.match(subject.command)
      expect(FileUtils).to receive(:rm_rf).with(match[1])
      subject.cleanup
    end
  end
end
