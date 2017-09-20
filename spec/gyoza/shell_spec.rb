require 'gyoza'

describe Gyoza::Shell do
  before :each do
    subject.stub :system => 'output'
  end

  describe '#run' do
    it "runs each supplied command with the path to ssh configuration" do
      expect(subject).to receive(:system).
        with({'GIT_ASKPASS' => Gyoza::Shell::EXECUTABLE}, 'foo')

      subject.run 'foo'
    end
  end
end
