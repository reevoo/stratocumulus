# encoding: UTF-8
require "spec_helper"

describe Stratocumulus::Database::PipeIO do
  subject do
    described_class.popen("echo foo")
  end

  after do
    subject.close
  end

  it "behaves like IO" do
    expect(subject.read).to eq "foo\n"
  end

  describe "#rewind" do
    it "is not defined" do
      expect(subject).to_not respond_to(:rewind)
    end
  end
end

describe IO do
  subject do
    described_class.open(
      described_class.sysopen("spec/support/test_config_file.yml"),
    )
  end

  it "is not affected" do
    subject.read
    subject.rewind
    expect(subject.read).to_not be_nil
  end
end
