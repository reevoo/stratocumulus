# encoding: UTF-8
require "spec_helper"

describe Stratocumulus::MySQL do
  subject do
    described_class.new(config)
  end

  let(:config) do
    { "name" => "stratocumulus_test" }
  end

  describe "#dependencies" do
    specify do
      expect(subject.dependencies).to eq %w(gzip mysqldump)
    end
  end

  describe "#command" do
    context "default" do
      it "generates the dump command with sensible defaults" do
        expect(subject.command).to eq(
          "mysqldump --single-transaction -uroot stratocumulus_test",
        )
      end
    end

    context "with the password set" do
      let(:config) do
        {
          "name" => "stratocumulus_test",
          "password" => "seecrit",
        }
      end

      it "generates the dump command with a default host" do
        expect(subject.command).to eq(
          "mysqldump --single-transaction -uroot -pseecrit stratocumulus_test",
        )
      end
    end

    context "with the port set" do
      let(:config) do
        {
          "name" => "stratocumulus_test",
          "port" => 13_306,
        }
      end

      it "generates the dump command with a default host" do
        expect(subject.command).to eq(
          "mysqldump --single-transaction -uroot -hlocalhost -P13306 stratocumulus_test" # rubocop:disable Metrics/LineLength
        )
      end
    end

    context "with the host set" do
      let(:config) do
        {
          "name" => "stratocumulus_test",
          "host" => "db.example.com",
        }
      end

      it "generates the dump command with a default port" do
        expect(subject.command).to eq(
          "mysqldump --single-transaction -uroot -hdb.example.com -P3306 stratocumulus_test" # rubocop:disable Metrics/LineLength
        )
      end
    end

    context "with the port and host set" do
      let(:config) do
        {
          "name" => "stratocumulus_test",
          "port" => 33_306,
          "host" => "db.example.com",
        }
      end

      it "generates the dump command with the port and host" do
        expect(subject.command).to eq(
          "mysqldump --single-transaction -uroot -hdb.example.com -P33306 stratocumulus_test" # rubocop:disable Metrics/LineLength
        )
      end
    end

    context "with the username set" do
      let(:config) do
        {
          "name" => "stratocumulus_test",
          "username" => "susan",
        }
      end

      it "generates the dump command with the username" do
        expect(subject.command).to eq(
          "mysqldump --single-transaction -ususan stratocumulus_test",
        )
      end
    end
  end
end
