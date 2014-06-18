# encoding: UTF-8
require 'spec_helper'

describe Stratocumulus::Database do

  subject do
    described_class.new(config)
  end

  let('config') do
    {
      'name' => 'stratocumulus_test',
      'type' => type
    }
  end

  describe '#dump' do
    context 'MySQL' do
      before do
        `mysql -u root < spec/support/mysql.sql`
      end

      let(:type) { 'mysql' }

      let(:dump) { Zlib::GzipReader.new(subject.dump).read }

      it 'sucessfully dumps a gziped copy of the database' do
        expect(dump).to include('CREATE TABLE `widgets`')
        expect(dump).to include("INSERT INTO `widgets` VALUES (1,'Foo',3,1,2)")
        expect(subject).to be_success
      end
    end

    context 'PostgreSQL' do
      before do
        `psql -U postgres < spec/support/psql.sql`
      end

      let(:type) { 'psql' }

      let(:dump) { Zlib::GzipReader.new(subject.dump).read }

      it 'sucessfully dumps a gziped copy of the database' do
        expect(dump).to include('CREATE TABLE widgets')
        expect(dump).to include(
          'COPY widgets (id, name, leavers, pivots, fulcrums) FROM stdin;'
        )
        expect(dump).to include('1	Foo	3	1	2')
        expect(subject).to be_success
      end
    end
  end
end
