module SocialSnippet::Api::ManifestApi

  # Initialize the snippet.json interactively.
  # $ sspm init
  def init_manifest(options = {})
    current_answers = load_manifest_file || {}
    answer = loop_manifest_questions(current_answers)
    core.storage.write "snippet.json", ::JSON.pretty_generate(answer)
    answer
  end

  private

  def loop_manifest_questions(answer)
    loop do
      answer = ask_manifest_questions(manifest_questions(answer), answer)
      output ""
      output ::JSON.pretty_generate(answer)
      output ""
      break if ask_confirm("Is this okay? [Y/N]: ")
    end
    answer
  end

  # load current configuration
  def load_manifest_file
    if core.storage.exists?("snippet.json")
      ::JSON.parse(core.storage.read "snippet.json")
    else
      nil
    end
  end

  def ask_confirm(message)
    ret = core.prompt.ask(message) do |q|
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
      core.prompt.ask("#{question[:key]}: ") do |q|
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
