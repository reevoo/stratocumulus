# encoding: UTF-8
require 'spec_helper'

describe Stratocumulus::Runner do
  subject { described_class.new('spec/support/test_config_file.yml') }
  let(:storage) { double(upload: true) }
  let(:database) { double }
  let(:database2) { double }

  before do
    allow(Stratocumulus::Storage).to receive(:new).and_return(storage)
  end

  after do
    subject.run
  end

  it 'passes the correct config to Storage' do
    expect(Stratocumulus::Storage).to receive(:new).once.with(
      'access_key_id' => 'I_AM_THE_KEY_ID',
      'secret_access_key' => 'IamTHESekret',
      'bucket' => 'stratocumulus-test',
      'region' => 'eu-west1'
    ).and_return(storage)
  end

  it 'passes each database config to instances of Database' do
    expect(Stratocumulus::Database).to receive(:new).once.with(
      'type' => 'mysql',
      'name' => 'stratocumulus_test',
      'storage' => 's3',
      'username' => 'root',
      'password' => 'sekret',
      'host' => 'db1.example.com',
      'port' => 3307
    )

    expect(Stratocumulus::Database).to receive(:new).once.with(
      'type' => 'mysql',
      'name' => 'stratocumulus_test_2',
      'storage' => 's3'
    )
  end

  it 'uploads each database to storage' do
    allow(Stratocumulus::Database).to receive(:new).once.with(
      hash_including('name' => 'stratocumulus_test')
    ).and_return(database)

    allow(Stratocumulus::Database).to receive(:new).once.with(
      hash_including('name' => 'stratocumulus_test_2')
    ).and_return(database2)

    expect(storage).to receive(:upload).once.with(database)
    expect(storage).to receive(:upload).once.with(database2)
  end
end
