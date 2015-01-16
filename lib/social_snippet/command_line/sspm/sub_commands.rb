module SocialSnippet::CommandLine::SSpm::SubCommands

  def self.all
    constants.select do |name|
      /.+Command$/ === name
    end
  end

end

require_relative "sub_commands/search_command"
require_relative "sub_commands/install_command"
require_relative "sub_commands/complete_command"
require_relative "sub_commands/info_command"
require_relative "sub_commands/update_command"
require_relative "sub_commands/publish_command"
require_relative "sub_commands/config_command"
