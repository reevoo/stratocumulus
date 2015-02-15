# encoding: UTF-8
require 'spec_helper'

describe Stratocumulus::PostgreSQL do
  subject do
    described_class.new(config)
  end

  let(:config) do
    { 'name' => 'stratocumulus_test' }
  end

  describe '#dependencies' do
    specify do
      expect(subject.dependencies).to eq %w(gzip pg_dump)
    end
  end

  describe '#command' do
    context 'default' do
      it 'generates the dump command with sensible defaults' do
        expect(subject.command).to eq(
          'pg_dump -Upostgres stratocumulus_test',
        )
      end
    end

    context 'with the password set' do
      let(:config) do
        {
          'name' => 'stratocumulus_test',
          'password' => 'sekret',
        }
      end

      it 'sets the password env var' do
        expect(subject.command).to eq(
          'PGPASSWORD="sekret" pg_dump -Upostgres stratocumulus_test',
        )
      end
    end

    context 'with the port set' do
      let(:config) do
        {
          'name' => 'stratocumulus_test',
          'port' => 15_432,
        }
      end

      it 'generates the dump command with a default host' do
        expect(subject.command).to eq(
          'pg_dump -Upostgres -hlocalhost -p15432 stratocumulus_test',
        )
      end
    end

    context 'with the host set' do
      let(:config) do
        {
          'name' => 'stratocumulus_test',
          'host' => 'db.example.com',
        }
      end

      it 'generates the dump command with a default port' do
        expect(subject.command).to eq(
          'pg_dump -Upostgres -hdb.example.com -p5432 stratocumulus_test',
        )
      end
    end

    context 'with the port and host set' do
      let(:config) do
        {
          'name' => 'stratocumulus_test',
          'port' => 15_432,
          'host' => 'db.example.com',
        }
      end

      it 'generates the dump command with port and host set' do
        expect(subject.command).to eq(
          'pg_dump -Upostgres -hdb.example.com -p15432 stratocumulus_test',
        )
      end
    end

    context 'with the username set' do
      let(:config) do
        {
          'name' => 'stratocumulus_test',
          'username' => 'susan',
        }
      end

      it 'generates the dump command with the username' do
        expect(subject.command).to eq(
          'pg_dump -Ususan stratocumulus_test',
        )
      end
    end
  end
end
