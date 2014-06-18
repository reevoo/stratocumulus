# encoding: UTF-8
require 'spec_helper'

describe Stratocumulus::Storage do
  let(:base_config) do
    {
      'access_key_id' => 'IM_A_ID',
      'secret_access_key' => 'IM_A_SEKRET_KEY',
      'region' =>  'eu-west-1',
      'bucket' =>  'stratocumulus-test'
    }
  end

  let(:config) { base_config }

  subject { described_class.new(config) }

  describe '#upload' do
    let(:connection) { double(:fog_conn, directories: directories) }
    let(:directories) { double(:fog_dirs, get: double(files: files)) }
    let(:files) { double(:fog_files, create: true) }

    let(:database) do
      double(:database, filename: 'foo.sql.gz', dump: :database_dump)
    end

    before do
      allow(Fog::Storage).to receive(:new).and_return(connection)
    end

    after do
      subject.upload(database)
    end

    it 'uploads the dump to s3' do
      expect(files).to receive(:create).with(
        key: 'foo.sql.gz',
        body: :database_dump,
        multipart_chunk_size: 104_857_600,
        public: false
      )
    end

    it 'uploads to the correct s3 bucket' do
      expect(directories).to receive(:get).with('stratocumulus-test')
    end

    describe 'the fog connection' do
      it 'is setup corectly' do
        expect(Fog::Storage).to receive(:new)
        .with(
          provider: 'AWS',
          aws_access_key_id: 'IM_A_ID',
          aws_secret_access_key: 'IM_A_SEKRET_KEY',
          region: 'eu-west-1'
        ).and_return(connection)
      end
    end

    context 'with a schedule' do
      let(:config) do
        base_config.merge(
          'retention' => {
            1 => 30
          }
        )
      end

      let(:directories) do
        double(:fog_dirs, get: double(files: files), service: service)
      end

      let(:service) { double(:fog_service) }

      context 'no rules set on the bucket yet' do
        before do
          allow(service).to receive(:get_bucket_lifecycle)
            .with('stratocumulus-test')
            .and_raise(Excon::Errors::NotFound, '404 No rules set yet')
        end

        it 'puts a rule for the uploaded file' do
          expect(service).to receive(:put_bucket_lifecycle)
            .with(
              'stratocumulus-test',
              'Rules' => [
                {
                  'ID' => 'foo.sql.gz',
                  'Prefix' => 'foo.sql.gz',
                  'Enabled' => true,
                  'Days' => 30
                }
              ]
            )
        end
      end

      context 'rules allready set on the bucket' do
        let(:files) { [existing_file] }
        let(:existing_file) { double(:fog_file, key: 'bar.sql.gz') }
        let(:existing_rules) do
          [
            {
              'ID' => 'bar.sql.gz',
              'Prefix' => 'bar.sql.gz',
              'Enabled' => true,
              'Days' => 30
            },
            {
              'ID' => 'baz.sql.gz',
              'Prefix' => 'baz.sql.gz',
              'Enabled' => true,
              'Days' => 30
            }
          ]
        end

        before do
          allow(service).to receive(:get_bucket_lifecycle)
            .with('stratocumulus-test')
            .and_return(
              double(
                data: {
                  body: {
                    'Rules' => existing_rules
                  }
                }
              )
            )
          allow(files).to receive(:create).and_return(:true)
        end

        it 'adds the rule to the rules for existing files' do
          expect(service).to receive(:put_bucket_lifecycle).with(
            'stratocumulus-test',
            'Rules' => [
              {
                'ID' => 'bar.sql.gz',
                'Prefix' => 'bar.sql.gz',
                'Enabled' => true,
                'Days' => 30
              },
              {
                'ID' => 'foo.sql.gz',
                'Prefix' => 'foo.sql.gz',
                'Enabled' => true,
                'Days' => 30
              }
            ]
          )
        end
      end
    end
  end
end
