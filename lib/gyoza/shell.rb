class Gyoza::Shell
  EXECUTABLE = File.expand_path '../../../exe/credentials', __FILE__

  def run(*commands)
    commands.each do |command|
      system({'GIT_ASKPASS' => EXECUTABLE}, command)
    end
  end
end
