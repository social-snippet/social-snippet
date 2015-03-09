module SocialSnippet::DocumentBackend

  $yaml_document_hash = ::Hash.new

  class YAMLDocument

    require_relative "yaml_document/query"

    attr_reader :path
    attr_reader :field_keys
    attr_reader :fields
    attr_reader :collection

    attr_accessor :id

    def initialize(options = {}, new_id = nil)
      @path   = self.class.path
      @collection = self.class.collection
      @fields = ::Hash.new
      @field_keys = self.class.field_keys
      init_fields options
      @id ||= new_id
    end

    def serialize
      attrs = field_keys.inject(::Hash.new) do |attrs, key|
        attrs[key] = fields[key]
        attrs
      end
      attrs[:id] = id
      attrs
    end

    def init_fields(options = {})
      field_keys.each do |k|
        fields[k] = self.class.default_field[k]
      end
      options.each do |k, v|
        fields[k] = v
      end
    end

    def remove
      collection.delete id
      self.class.update_file!
    end

    def save!
      collection[id] = serialize
      self.class.update_file!
    end

    class << self

      # "Callback invoked whenever a subclass of the current class is created."
      # http://docs.ruby-lang.org/en/2.2.0/Class.html#method-i-inherited
      def inherited(child)
        load_file!
      end

      def load_file!
        $yaml_document_hash ||= ::YAML.load(::File.read path)
      end

      def set_path(new_path)
        @path = new_path
        ::FileUtils.touch(path) unless ::File.exists?(path)
      end

      def path
        if self != ::SocialSnippet::DocumentBackend::YAMLDocument
          ::SocialSnippet::DocumentBackend::YAMLDocument.path
        else
          @path
        end
      end

      def update_file!
        ::File.write path, $yaml_document_hash.to_yaml
      end

      def find(id)
        if collection.has_key?(id)
          new collection[id], id
        else
          raise "ERROR: not found document"
        end
      end

      def where(cond)
        Query.new(collection).find cond
      end

      def collection
        collection ||= create_collection
      end

      def create_collection
        $yaml_document_hash[self.to_s.downcase] ||= ::Hash.new
      end

      def field_keys
        @field_keys
      end

      def default_field
        @default_field
      end

      def field(sym, options = {})
        @field_keys ||= ::Set.new
        @default_field ||= ::Hash.new

        default_field[sym] = options[:default] unless options[:default].nil?

        field_keys.add sym

        # define getter
        define_method sym do
          @fields[sym]
        end

        # define setter
        define_method "#{sym}=" do |v|
          @fields[sym] = v
        end
      end

      def create(options = {})
        doc = new
        options.each {|k, v| doc.send "#{k}=", v }
        doc
      end

      # replace self with ::SocialSnippet::Document class
      def activate!
        ::SocialSnippet.class_eval do
          remove_const :Document
          const_set :Document, YAMLDocument
        end
      end

    end # class << self

  end

end
