module SocialSnippet::Repository::Models

  class Package < ::SocialSnippet::Document

    @@core = nil

    # set from snippet.json
    attr_reader :name
    attr_reader :dependencies
    attr_reader :main
    attr_reader :desc

    field :repo_name, :type => String  # key
    field :rev_hash, :type => String   # key
    field :paths, :type => Array, :default => ::Array.new

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

    def snippet_json_text
      json_path = real_path("snippet.json")
      core.storage.read json_path
    end

    def load_snippet_json
      snippet_json = ::JSON.parse(snippet_json_text)
      @name = snippet_json["name"]
      @desc = snippet_json["desc"]
      @main = snippet_json["main"] || ""
      @dependencies = snippet_json["dependencies"] || {}
    end

    def glob(glob_pattern)
      paths.select do |path|
        ::File.fnmatch glob_pattern, path, ::File::FNM_PATHNAME
      end
    end

    def real_path(path = nil)
      core.config.package_path repo_name, rev_hash, path
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

