module SocialSnippet::Api::ManifestApi

  # Initialize the snippet.json interactively.
  # $ sspm init
  def init_manifest(options = {})
    answer = {}
    json_str = "{}"

    # load current configuration
    if ::File.exists?("snippet.json")
      answer = ::JSON.parse(::File.read "snippet.json")
    end

    loop do
      answer = ask_manifest_questions(manifest_questions(answer), answer)
      json_str = ::JSON.pretty_generate(answer)
      social_snippet.logger.say ""
      social_snippet.logger.say json_str
      social_snippet.logger.say ""
      break if ask_confirm("Is this okay? [Y/N]: ")
    end

    ::File.write "snippet.json", json_str

    answer
  end

end
