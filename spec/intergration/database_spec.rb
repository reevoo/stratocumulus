# encoding: UTF-8
require 'spec_helper'

describe Stratocumulus::Database do

  subject do
    described_class.new(config)
  end

  let('config') do
    {
      'name' => 'stratocumulus_test',
      'type' => 'mysql'
    }
  end

  describe '#dump' do
    before do
      system('mysql -u root < spec/support/test.sql')
    end

    let(:dump) { Zlib::GzipReader.new(subject.dump).read }

    it 'sucessfully dumps a gziped copy of the database' do
      expect(dump).to include('CREATE TABLE `widgets`')
      expect(dump).to include("INSERT INTO `widgets` VALUES (1,'Foo',3,1,2)")
      expect(subject).to be_success
    end
  end
end
