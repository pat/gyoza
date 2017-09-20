require 'gyoza'

describe Gyoza::Change do
  let(:change) { Gyoza::Change.new user: 'joshk', repo: 'travis',
    file: 'index.textile', subject: 'merge please', contents: 'new content',
    author: 'pat <me@pat.com>', nickname: 'pat' }
  let(:gh)     { double :[] => {:hash => :foo}, post: true }
  let(:shell)  { double run: true, unlink: true }
  let(:file)   { double print: true }

  before :each do
    allow(GH).to receive_messages tap: gh
    allow(Gyoza::Shell).to receive_messages new: shell
    allow(Dir).to receive_messages mktmpdir: '/tmp/path', chdir: true
    allow(FileUtils).to receive_messages remove_entry: true
    allow(Time).to receive_message_chain(:zone, :now, :to_i).and_return 456123
    allow(File).to receive(:open).and_yield file

    allow(change).to receive_messages sleep: true
    allow(gh).to receive_message_chain(:current, :setup).and_return true
  end

  describe '#change' do
    it "uses the existing fork when there is one" do
      expect(gh).not_to receive(:post).with '/repos/joshk/travis/forks', {}

      change.change
    end

    it "creates a new fork when necessary" do
      calls = 0

      allow(gh).to receive(:[]) do |path|
        calls += 1
        raise GH::Error if calls == 1
      end

      expect(gh).to receive(:post).with '/repos/joshk/travis/forks', {}

      change.change
    end

    it "clones the repo into the tmp directory" do
      expect(shell).to receive(:run).with('git clone --branch gh-pages https://gyozadoc@github.com/gyozadoc/travis /tmp/path/travis')

      change.change
    end

    it "changes the directory to the cloned repo" do
      expect(Dir).to receive(:chdir).with('/tmp/path/travis')

      change.change
    end

    it "updates the fork to the latest from the main repo" do
      expect(shell).to receive(:run).with(
        'git remote add joshk git://github.com/joshk/travis',
        'git fetch joshk',
        'git merge joshk/gh-pages',
        'git push origin gh-pages'
      )

      change.change
    end

    it "creates a new branch with a timestamp" do
      expect(shell).to receive(:run).with('git checkout -b patch-456123')

      change.change
    end

    it "opens the file for patching" do
      expect(File).to receive(:open).with('/tmp/path/travis/index.textile', 'w').
        and_yield file

      change.change
    end

    it "patches the file with the supplied changes" do
      expect(file).to receive(:print).with('new content')

      change.change
    end

    it "commits and pushes the changed file" do
      expect(shell).to receive(:run).with(
        'git config user.email "me@pat.com"',
        'git config user.name "pat"',
        'git add index.textile',
        'git commit --message="merge please" --author="pat <me@pat.com>"',
        'git push origin patch-456123'
      )

      change.change
    end

    it "adds a pull request using the patch branch" do
      expect(gh).to receive(:post).with 'repos/joshk/travis/pulls', {
        'title' => 'merge please',
        'body'  => 'Contributed by @pat',
        'head'  => 'gyozadoc:patch-456123',
        'base'  => 'gh-pages'
      }

      change.change
    end

    it "changes the directory back to root" do
      expect(Dir).to receive(:chdir).with '/'

      change.change
    end

    it "removes the temp directory" do
      expect(FileUtils).to receive(:remove_entry).with '/tmp/path'

      change.change
    end
  end
end
