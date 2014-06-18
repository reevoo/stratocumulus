# encoding: UTF-8
require 'spec_helper'

describe Stratocumulus::Retention do
  subject { described_class.new(schedule) }

  let(:schedule) do
    {
      1 => 30,
      7 => 8,
      30 => 12
    }
  end

  let(:keep_for_a_month) do
    (1..365).to_a - keep_for_two_months - keep_for_a_year
  end

  let(:keep_for_two_months) do
    (1..56).map { |i| i * 7 } - keep_for_a_year
  end

  let(:keep_for_a_year) do
    (1..12).map { |i| i * 30 }
  end

  let(:key) { 'testdb/testdbTIMESTAMP.sql.gz' }

  let(:expires_in_days) { subject.rule(key)['Days'] }

  describe '#rule' do

    it 'returns a rule with the key and an expiry' do
      stub_yday(30)
      expect(subject.rule(key)).to eq(
        'Days' => 360,
        'Enabled' => true,
        'ID' => key,
        'Prefix' => key
      )
    end

    it 'it keeps a daily backup for a month' do
      keep_for_a_month.each do |day|
        stub_yday(day)
        expect(expires_in_days).to eq 30
      end
    end

    it 'keeps a weekly backup for 8 weeks' do
      keep_for_two_months.each do |day|
        stub_yday(day)
        expect(expires_in_days).to eq 56
      end
    end

    it 'keeps a monthly backup for 12 months' do
      keep_for_a_year.each do |day|
        stub_yday(day)
        expect(expires_in_days).to eq 360
      end
    end

    context 'a non daily schedule' do
      let(:schedule) do
        { 14 => 2 }
      end

      let(:days_to_keep) do
        (1..28).map { |i| i * 14 }
      end

      let(:days_not_to_keep) do
        (1..365).to_a - days_to_keep
      end

      it 'keeps fortightly backups for 2 fortnights' do
        days_to_keep.each do |day|
          stub_yday(day)
          expect(subject.upload_today?).to be_truthy
          expect(expires_in_days).to eq 28
        end
      end

      it 'keeps nothing on the other days' do
        days_not_to_keep.each do |day|
          stub_yday(day)
          expect(subject.upload_today?).to be_falsy
        end
      end
    end

    context 'with no schedule' do
      let(:schedule) { nil }

      it 'runs the backup' do
        expect(subject.upload_today?).to eq true
      end

      it 'keeps the backup forever' do
        expect(subject.rule(key)).to be_nil
      end
    end

    def stub_yday(day)
      day = double(yday: day)
      allow(Date).to receive(:today).and_return(day)
    end
  end
end
