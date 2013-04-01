class Gyoza::Shell
  def run(*commands)
    commands.each do |command|
      system({'GIT_SSH' => ssh_file.path}, command)
    end
  end

  def unlink
    key_file.unlink
    ssh_file.unlink
  end

  private

  def key_file
    @key_file ||= Tempfile.new('private.key').tap do |file|
      file.write Gyoza::GITHUB_PRIVATE_KEY
    end
  end

  def ssh_file
    @ssh_file ||= Tempfile.new('ssh.config').tap do |file|
      file.write <<-SSH
Host github
HostName #{Gyoza::GITHUB}
Port 22
IdentityFile #{key_file.path}
IdentitiesOnly yes
StrictHostKeyChecking no
UserKnownHostsFile /dev/null
      SSH
    end
  end
end
