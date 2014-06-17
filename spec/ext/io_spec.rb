# encoding: UTF-8
require 'spec_helper'

describe IO do
  subject { IO.new(IO.sysopen('/dev/null', 'w')) }

  describe '#rewind' do
    it 'is not defined' do
      expect(subject).to_not respond_to(:rewind)
    end
  end
end
