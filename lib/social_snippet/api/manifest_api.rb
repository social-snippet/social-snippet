module SocialSnippet::Api::ManifestApi

  require "json"

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

  private

  def ask_confirm(message)
    ret = social_snippet.prompt.ask(message) do |q|
      q.limit = 1
      q.validate = /^[yn]$/i
    end
    /y/i === ret
  end

  def ask_manifest_questions(questions, obj)
    questions.inject(obj) do |obj, q|
      obj[q[:key]] = ask_manifest_question(q)
      obj
    end
  end

  def ask_manifest_question(question)
    if question[:type] === :string
      social_snippet.prompt.ask("#{question[:key]}: ") do |q|
        q.default = question[:default]
        if question[:validate].is_a?(Regexp)
          q.validate = question[:validate]
        end
      end
    end
  end

  def manifest_questions(answer)
    [
      {
        :key => "name",
        :type => :string,
        :validate => /[a-zA-Z0-9\.\-_]+/,
        :default => answer["name"],
      },
      {
        :key => "description",
        :type => :string,
        :default => answer["description"],
      },
      {
        :key => "license",
        :default => answer["license"] || "MIT",
        :type => :string,
      },
    ]
  end

end
