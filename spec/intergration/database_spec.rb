# encoding: UTF-8
require 'spec_helper'
require 'zlib'
require 'rubygems/package'

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

  let(:dump) { Zlib::GzipReader.new(subject.dump).read }

  describe '#dump' do
    context 'MySQL' do
      before do
        `mysql -u root < spec/support/mysql.sql`
      end

      let(:type) { 'mysql' }

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

      it 'sucessfully dumps a gziped copy of the database' do
        expect(dump).to include('CREATE TABLE widgets')
        expect(dump).to include(
          'COPY widgets (id, name, leavers, pivots, fulcrums) FROM stdin;'
        )
        expect(dump).to include('1	Foo	3	1	2')
        expect(subject).to be_success
      end
    end

    context 'RethinkDB' do
      before do
        `rethinkdb restore --force spec/support/rethinkdb.tar.gz`
      end

      let(:type) { 'rethinkdb' }

      let(:tarball) { Zlib::GzipReader.new(subject.dump) }

      let(:dump) do
        Gem::Package::TarReader.new(tarball).each do |tarfile|
          next unless tarfile.full_name =~ /widgets.json/
          return JSON.load(tarfile.read)
        end
      end

      let(:expected_data) do
        [
          # rubocop:disable Style/LineLength
          { 'pivots' => 5, 'fulcrums' => 3, 'leavers' => 8, 'id' => '1c66308d-492e-48ee-bfc5-83de96a15236', 'name' => 'Plugh' },
          { 'pivots' => 2, 'fulcrums' => 3, 'leavers' => 1, 'id' => '224ba4b1-2184-4905-b81b-ac6368480f43', 'name' => 'Thud' },
          { 'pivots' => 2, 'fulcrums' => 3, 'leavers' => 1, 'id' => '25b68062-7e9f-4fca-92bf-672287961096', 'name' => 'Garply' },
          { 'pivots' => 1, 'fulcrums' => 2, 'leavers' => 3, 'id' => '380c2a12-62d8-4faa-968e-79b2919bf9ad', 'name' => 'Foo' },
          { 'pivots' => 5, 'fulcrums' => 4, 'leavers' => 8, 'id' => '46cd4d4a-2cca-4ae2-835e-19c94c53ce02', 'name' => 'Quux' },
          { 'pivots' => 2, 'fulcrums' => 7, 'leavers' => 8, 'id' => '63441f79-cfe4-4460-8fc7-bda802e93646', 'name' => 'Corge' },
          { 'pivots' => 3, 'fulcrums' => 4, 'leavers' => 7, 'id' => '7d83f209-b4b1-4463-9eec-42dbf9217a39', 'name' => 'Grault' },
          { 'pivots' => 5, 'fulcrums' => 6, 'leavers' => 4, 'id' => '8e1623c8-e28d-48f9-8d74-dc5bf459cff5', 'name' => 'Qux' },
          { 'pivots' => 2, 'fulcrums' => 0, 'leavers' => 2, 'id' => 'a59c4505-c078-4186-a1d5-b0120dba4aa1', 'name' => 'Bar' },
          { 'pivots' => 3, 'fulcrums' => 3, 'leavers' => 3, 'id' => 'b535529c-c822-4c08-af65-f3662d981046', 'name' => 'Xyzzy' },
          { 'pivots' => 0, 'fulcrums' => 0, 'leavers' => 0, 'id' => 'f47bcc2a-ae2a-4d5f-9bbf-df71c8d81a7a', 'name' => 'Waldo' },
          { 'pivots' => 6, 'fulcrums' => 4, 'leavers' => 5, 'id' => 'f6745b27-b0c8-40ca-a472-dbe45310ee19', 'name' => 'Baz' },
          { 'pivots' => 1, 'fulcrums' => 1, 'leavers' => 1, 'id' => 'f88a0196-faaa-4695-88f1-808555a68ffa', 'name' => 'Fred' }
          # rubocop:enable Style/LineLength
        ]
      end

      it 'sucessfully dumps a gziped copy of the database' do
        expect(dump).to eq expected_data
        expect(subject).to be_success
      end
    end
  end
end
