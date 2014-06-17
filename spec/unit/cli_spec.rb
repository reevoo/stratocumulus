# encoding: UTF-8
require 'spec_helper'

describe Stratocumulus::Cli do
  describe '#backups' do
    let(:runner) { double }

    it 'calls the runner with the path' do
      expect(Stratocumulus::Runner).to receive(:new)
        .with('/path/to/config.yml').and_return(runner)

      expect(runner).to receive(:run)

      subject.backup '/path/to/config.yml'
    end
  end
end
