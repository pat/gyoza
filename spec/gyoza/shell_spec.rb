require 'gyoza'

describe Gyoza::Shell do
  let(:ssh_file) { double path: '/tmp/ssh/config',  write: true, unlink: true }
  let(:key_file) { double path: '/tmp/private.key', write: true, unlink: true }
  let(:logger)   { double debug: true }

  before :each do
    stub_const 'Gyoza::GITHUB_PRIVATE_KEY', 'generated-key'
    Tempfile.stub(:new).and_return ssh_file, key_file
  end

  describe '#run' do
    before :each do
      stub_const 'Rails', double(logger: logger)
      subject.stub :` => 'output'
    end

    it "runs each supplied command with the path to ssh configuration" do
      subject.should_receive(:`).with('GIT_SSH=/tmp/ssh/config foo')

      subject.run 'foo'
    end

    it "generates a temporary private key file" do
      key_file.should_receive(:write).with('generated-key')

      subject.run 'foo'
    end

    it "generates a temporary ssh configuration file" do
      ssh_file.should_receive(:write).with <<-CONFIG
Host github
HostName github.com
Port 22
IdentityFile /tmp/private.key
IdentitiesOnly yes
StrictHostKeyChecking no
UserKnownHostsFile /dev/null
      CONFIG

      subject.run 'foo'
    end
  end

  describe '#unlink' do
    it "unlinks the key file" do
      key_file.should_receive(:unlink)

      subject.unlink
    end

    it "unlinks the ssh configuration file" do
      ssh_file.should_receive(:unlink)

      subject.unlink
    end
  end
end
