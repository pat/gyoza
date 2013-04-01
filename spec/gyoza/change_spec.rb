require 'gyoza'

describe Gyoza::Change do
  let(:change) { Gyoza::Change.new user: 'joshk', repo: 'travis',
    file: 'index.textile', subject: 'merge please', contents: 'new content',
    author: 'pat <me@pat.com>', nickname: 'pat' }
  let(:gh)     { double :[] => {:hash => :foo}, post: true }
  let(:shell)  { double run: true, unlink: true }
  let(:file)   { double print: true }

  before :each do
    GH.stub tap: gh
    Gyoza::Shell.stub new: shell
    Dir.stub mktmpdir: '/tmp/path', chdir: true
    FileUtils.stub remove_entry: true
    Time.stub_chain(:zone, :now, :to_i).and_return 456123
    File.stub(:open).and_yield file

    change.stub sleep: true
    gh.stub_chain(:current, :setup).and_return true
  end

  describe '#change' do
    it "uses the existing fork when there is one" do
      gh.should_not_receive(:post).with '/repos/joshk/travis/forks', {}

      change.change
    end

    it "creates a new fork when necessary" do
      calls = 0

      gh.stub(:[]) do |path|
        calls += 1
        raise GH::Error if calls == 1
      end

      gh.should_receive(:post).with '/repos/joshk/travis/forks', {}

      change.change
    end

    it "clones the repo into the tmp directory" do
      shell.should_receive(:run).with('git clone --branch gh-pages git@github.com:gyozadoc/travis /tmp/path/travis')

      change.change
    end

    it "changes the directory to the cloned repo" do
      Dir.should_receive(:chdir).with('/tmp/path/travis')

      change.change
    end

    it "updates the fork to the latest from the main repo" do
      shell.should_receive(:run).with(
        'git remote add joshk git://github.com/joshk/travis',
        'git fetch joshk',
        'git merge joshk/gh-pages',
        'git push origin gh-pages'
      )

      change.change
    end

    it "creates a new branch with a timestamp" do
      shell.should_receive(:run).with('git checkout -b patch-456123')

      change.change
    end

    it "opens the file for patching" do
      File.should_receive(:open).with('/tmp/path/travis/index.textile', 'w').
        and_yield file

      change.change
    end

    it "patches the file with the supplied changes" do
      file.should_receive(:print).with('new content')

      change.change
    end

    it "commits and pushes the changed file" do
      shell.should_receive(:run).with(
        'git add index.textile',
        'git commit --message="merge please" --author="pat <me@pat.com>"',
        'git push origin patch-456123'
      )

      change.change
    end

    it "adds a pull request using the patch branch" do
      gh.should_receive(:post).with 'repos/joshk/travis/pulls', {
        'title' => 'merge please',
        'body'  => 'Contributed by @pat',
        'head'  => 'gyozadoc:patch-456123',
        'base'  => 'gh-pages'
      }

      change.change
    end

    it "changes the directory back to root" do
      Dir.should_receive(:chdir).with '/'

      change.change
    end

    it "removes the temp directory" do
      FileUtils.should_receive(:remove_entry).with '/tmp/path'

      change.change
    end

    it "removes the temporary shell files" do
      shell.should_receive :unlink

      change.change
    end
  end
end
