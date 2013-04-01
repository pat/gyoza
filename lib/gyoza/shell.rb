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
      file.close
    end
  end

  def ssh_file
    @ssh_file ||= Tempfile.new('ssh.config').tap do |file|
      file.write <<-SSH
#!/bin/sh
exec /usr/bin/ssh -o StrictHostKeyChecking=no -o IdentitiesOnly=yes -o UserKnownHostsFile=/dev/null -i #{key_file.path} "$@"
      SSH
      file.close
      system "chmod +x #{file.path}"
    end
  end
end
