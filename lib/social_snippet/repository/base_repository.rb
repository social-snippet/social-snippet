module SocialSnippet
  module Repository
    # Repository base class
    # usage: class GitRepository < BaseRepository
    class BaseRepository
      attr_reader :path
      attr_reader :cache_path
      attr_reader :name
      attr_reader :desc
      attr_reader :main
      attr_reader :ref
      attr_reader :dependencies
      attr_reader :ref
      attr_reader :url

      # Constructor
      #
      # @param path [String] The path of repository
      def initialize(new_path, new_ref = nil)
        @path = new_path
        @cache_path = nil
        @ref = new_ref

        unless ref.nil?
          unless get_refs.empty?
            unless get_refs.include?(ref)
              raise Errors::NotExistRef
            end
          end
        end
        @url = nil
      end

      # Set repo's URL
      def set_url(new_url)
        @url = new_url
      end

      # Create repository cache
      #
      # @param cache_path [String] The path of cache dir
      def create_cache(base_cache_path)
        cache_to = get_commit_id[0..7]
        @cache_path = "#{base_cache_path}/#{name}/#{cache_to}"
        return if Dir.exists?(@cache_path)
        FileUtils.mkdir_p "#{base_cache_path}/#{name}"
        FileUtils.cp_r path, cache_path
      end

      # Load snippet.json file
      def load_snippet_json
        text = File.read("#{path}/snippet.json")
        snippet_json = JSON.parse(text)
        @name = snippet_json["name"]
        @desc = snippet_json["desc"]
        @main = snippet_json["main"] || ""
        @dependencies = snippet_json["dependencies"] || {}
      end

      # Get JSON text from repo instance
      # 
      # @return JSON text
      def to_snippet_json
        required = [
          :name,
        ]

        optional = [
          :desc,
          :main,
          :dependencies,
        ]

        data = {}
        required.each do |key|
          data[key] = send(key)
        end
        optional.each do |key|
          val = send(key)
          if val.nil? === false && val != ""
            data[key] = send(key)
          end
        end
        return data.to_json
      end

      # Get latest version
      #
      # @param pattern [String] The pattern of version
      # @return [String] The version
      def get_latest_version(pattern = "")
        pattern = "" if pattern.nil?
        versions = get_versions.select {|ref| Version.is_matched_version_pattern(pattern, ref)}
        return VersionSorter.rsort(versions).first
      end

      # Get all versions
      #
      # @return [Array<String>] All versions of repository
      def get_versions
        return get_refs.select {|ref| Version.is_version(ref) }
      end

      # Get all refs
      #
      # @return [Array<String>] All references of repository
      def get_refs
        raise "not implement get_refs"
      end

      # Get short current ref's commit id
      #
      # @return [String]
      def get_short_commit_id
        return get_commit_id[0..7]
      end

      # Get current ref's commit id
      #
      # @return [String]
      def get_commit_id
        raise "not implement get_commit_id"
      end

      # Get real path
      #
      # @param target_path [String] The real path of repo's file or directory
      def get_real_path(target_path)
        if is_cached?
          return "#{cache_path}/#{main}/#{target_path}"
        else
          return "#{path}/#{main}/#{target_path}"
        end
      end

      # Checkout to ref
      #
      # @param ref [String] The reference of repository
      def checkout(new_ref)
        raise "not implement checkout"
      end

      # Check repository has version ref
      #
      # @return [Boolean]
      def has_versions?
        return get_versions.empty? === false
      end

      # Check repository is cached
      #
      # @return [Boolean]
      def is_cached?
        return @cache_path.nil? === false
      end
    end
  end
end
