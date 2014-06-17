# encoding: UTF-8
require 'spec_helper'

describe Stratocumulus::Storage do
  let(:config) do
    {
      'access_key_id' => 'IM_A_ID',
      'secret_access_key' => 'IM_A_SEKRET_KEY',
      'region' =>  'eu-west-1',
      'bucket' =>  'stratocumulus-test'
    }
  end

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
  end

end
