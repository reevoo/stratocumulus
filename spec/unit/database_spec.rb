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
      'type' => 'mysql'
    }
  end

  before do
    allow_any_instance_of(described_class).to receive(:system).and_return(true)
  end

  describe '.new' do
    context 'the database type is not mysql' do
      let(:config) { base_config.merge('type' => 'nosqlioid') }

      it 'thows an error unless the type is mysql' do
        expect { subject }.to raise_error(
          RuntimeError,
          'nosqlioid is not a supported database'
        )
      end
    end

    it 'throws an error if mysqldump is not installed' do
      allow_any_instance_of(described_class)
        .to  receive(:system).with(/which mysqldump/)

      expect { subject }.to raise_error(
        RuntimeError,
        'mysqldump not available'
      )
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

    after do
      subject.dump
    end

    describe 'username' do
      context 'default' do
        it 'uses root' do
          expect(IO).to receive(:popen) do |command|
            expect(command).to include(' -uroot ')
          end
        end
      end

      context 'setting the username' do
        let(:config) { base_config.merge('username' => 'susan') }

        it 'uses the correct username' do
          expect(IO).to receive(:popen) do |command|
            expect(command).to include(' -ususan ')
          end
        end
      end
    end

    describe 'password' do
      context 'default' do
        it 'uses no password' do
          expect(IO).to receive(:popen) do |command|
            expect(command).to_not include('-p')
          end
        end
      end

      context 'setting the passsword' do
        let(:config) { base_config.merge('password' => 'sekret') }

        it 'uses the correct password' do
          expect(IO).to receive(:popen) do |command|
            expect(command).to include(' -psekret ')
          end
        end
      end
    end

    describe 'host' do
      context 'default with the port set' do
        let(:config) { base_config.merge('port' => '3306') }

        it 'uses localhost' do
          expect(IO).to receive(:popen) do |command|
            expect(command).to include(' -hlocalhost ')
          end
        end
      end

      context 'default' do
        it 'uses the default socket' do
          expect(IO).to receive(:popen) do |command|
            expect(command).to_not include(' -hlocalhost ')
          end
        end
      end

      context 'setting the host' do
        let(:config) { base_config.merge('host' => 'db.awesome-server.net') }

        it 'uses the correct hostname' do
          expect(IO).to receive(:popen) do |command|
            expect(command).to include(' -hdb.awesome-server.net ')
          end
        end
      end
    end

    describe 'port' do
      context 'default with the host set' do
        let(:config) { base_config.merge('host' => 'db.awesome-server.net') }

        it 'uses 3306' do
          expect(IO).to receive(:popen) do |command|
            expect(command).to include(' -P3306 ')
          end
        end
      end

      context 'default' do
        it 'uses the default socket' do
          expect(IO).to receive(:popen) do |command|
            expect(command).to_not include(' -P3306 ')
          end
        end
      end

      context 'setting the port' do
        let(:config) { base_config.merge('port' => '4306') }

        it 'uses the correct port' do
          expect(IO).to receive(:popen) do |command|
            expect(command).to include(' -P4306 ')
          end
        end
      end
    end

    describe 'the dump command' do
      it 'sets pipefail' do
        expect(IO).to receive(:popen) do |command|
          expect(command).to include("bash -c 'set -o pipefail;")
        end
      end

      it 'uses mysqldump --single-transaction option to not lock tables' do
        expect(IO).to receive(:popen) do |command|
          expect(command).to include(' mysqldump --single-transaction ')
        end
      end

      it 'pipes the output of mysql to gzip' do
        expect(IO).to receive(:popen) do |command|
          expect(command).to match(/.*mysqldump.*\| gzip/)
        end
      end
    end
  end

  describe '#filename' do
    it 'calculates a filename based on the name and timestamp' do
      timestamp = Time.now.utc.strftime('%Y%m%d%H%M')
      filename = "stratocumulus_test/stratocumulus_test.#{timestamp}.sql.gz"
      expect(subject.filename).to eq filename
    end
  end
end
