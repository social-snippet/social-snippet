module SocialSnippet::Repository::Models

  class Package < ::SocialSnippet::Document

    @@core = nil

    field :repo_name, :type => String  # key
    field :rev_hash, :type => String   # key
    field :name, :type => String
    field :paths, :type => Array, :default => ::Array.new
    field :dependencies, :type => Hash, :default => ::Hash.new

    def display_name
      name || "#{repo_name}@#{rev_hash}"
    end

    def normalize_path(path)
      ::Pathname.new(path).cleanpath.to_s
    end

    def add_path(path)
      push :paths => path
    end

    def add_directory(path)
      path = normalize_path(path)
      add_path path + "/"
      dir_path = real_path(path)
      core.storage.mkdir_p dir_path
    end

    def add_file(path, data)
      path = normalize_path(path)
      add_path path
      file_path = real_path(path)
      core.storage.mkdir_p ::File.dirname(file_path)
      core.storage.write file_path, data
    end

    def add_dependency(name, ref)
      modifier = ::Hash.new
      modifier[name] = ref
      push_to_hash :dependencies => modifier
    end

    def push_to_hash(attrs)
      attrs.each do |key, modifier|
        send(key).merge! modifier
      end
      save!
    end

    def has_dependencies?
      not dependencies.empty?
    end

    def snippet_json_text
      json_path = real_path("snippet.json")
      core.storage.read json_path
    end

    def snippet_json
      @snippet_json ||= parse_snippet_json
    end

    def parse_snippet_json
      ::JSON.parse(snippet_json_text)
    end

    def glob(glob_pattern)
      paths.select do |path|
        ::File.fnmatch glob_pattern, path, ::File::FNM_PATHNAME
      end
    end

    def real_path(path = nil)
      core.config.package_path repo_name, rev_hash, path
    end

    # path from snippet_json["main"]
    def snippet_path(path = nil)
      if snippet_json["main"].nil?
        real_path path
      else
        real_path ::File.join(snippet_json["main"], path)
      end
    end

    def core
      @@core
    end

    def self.core
      @@core
    end

    def self.core=(new_core)
      @@core = new_core
    end

  end # Package

end # ::SocialSnippet::Repository::Models

