# encoding: UTF-8
require 'spec_helper'

describe Stratocumulus::Database::Base do
  describe '#success?' do
    describe 'the dump fails' do
      subject { FailingDatabase.new }

      it 'returns false' do
        expect(subject).to_not be_success
      end
    end

    describe 'the dump is sucessfull' do
      subject { SucessDatabase.new }

      it 'returns false' do
        expect(subject).to be_success
      end
    end
  end

  class SucessDatabase < described_class
    def command
      'echo boo'
    end
  end

  class FailingDatabase < described_class
    def command
      'exit 127'
    end
  end
end
