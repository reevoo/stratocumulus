# encoding: UTF-8
require 'spec_helper'

describe Stratocumulus::Database do

  subject do
    described_class.new(config)
  end

  let(:config) { base_config }

  let(:base_config) do
    {
      'name' => 'stratocumulus_test',
      'type' => type
    }
  end

  let(:type) { 'mysql' }

  before do
    allow_any_instance_of(described_class).to receive(:system).and_return(true)
  end

  describe '.new' do
    context 'the database type is not supported' do
      let(:config) { base_config.merge('type' => 'nosqlioid') }

      it 'thows an error unless the type is supported' do
        expect { subject }.to raise_error(
          RuntimeError,
          'nosqlioid is not a supported database'
        )
      end
    end

    context 'mysql' do
      it 'throws an error if mysqldump is not installed' do
        allow_any_instance_of(described_class)
        .to  receive(:system).with(/which mysqldump/)

        expect { subject }.to raise_error(
          RuntimeError,
          'mysqldump not available'
        )
      end
    end

    context 'postgresql' do
      let(:type) { 'psql' }

      it 'throws an error if pg_dump is not installed' do
        allow_any_instance_of(described_class)
        .to  receive(:system).with(/which pg_dump/)

        expect { subject }.to raise_error(
          RuntimeError,
          'pg_dump not available'
        )
      end
    end

    it 'throws an error if gzip is not installed' do
      allow_any_instance_of(described_class)
        .to receive(:system).with(/which gzip/)

      expect { subject }.to raise_error(
        RuntimeError,
        'gzip not available'
      )
    end

    context 'when no database name is provided' do

      let(:config) do
        { 'type' => 'mysql' }
      end

      it 'throws an error' do
        expect { subject }.to raise_error(
          RuntimeError,
          'database name not specified'
        )
      end

    end
  end

  describe 'dump' do

    subject do
      described_class.new(
        base_config,
        ScaryBackend
      )
    end

    after do
      subject.dump
    end

    it 'uses the command from the backend | gzip' do
      expect(IO).to receive(:popen) do |command|
        expect(command).to eq "bash -c 'set -o pipefail; echo boo | gzip'"
      end
    end
  end

  describe '#filename' do
    it 'calculates a filename based on the name and timestamp' do
      timestamp = Time.now.utc.strftime('%Y%m%d%H%M')
      filename = "stratocumulus_test/stratocumulus_test.#{timestamp}.sql.gz"
      expect(subject.filename).to eq filename
    end

    it 'stays the same for an instance even if time moves on' do
      filename = subject.filename
      allow(Time).to receive(:now).and_return(Time.now + 60 * 60 * 26)
      expect(subject.filename).to eq filename
    end
  end

  describe '#success?' do
    subject  do
      described_class.new(
        base_config,
        backend
      )
    end

    context 'the backend fails' do
      let(:backend) { FailingBackend }

      it 'returns false' do
        expect(subject).to_not be_success
      end

    end

    context 'the backend is sucessfull' do
      let(:backend) { SucessBackend }

      it 'returns true' do
        expect(subject).to be_success
      end

    end

    class FakeBackend
      def initialize(*)
      end

      def dependencies
        []
      end
    end

    class FailingBackend < FakeBackend
      def command
        'exit 127'
      end
    end

    class SucessBackend < FakeBackend
      def command
        'exit 0'
      end
    end

    class ScaryBackend < FakeBackend
      def command
        'echo boo'
      end
    end
  end
end
