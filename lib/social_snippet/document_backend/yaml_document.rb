module SocialSnippet::DocumentBackend

  $yaml_document_hash = nil

  class YAMLDocument

    @@path = nil

    require_relative "yaml_document/query"

    attr_reader :path
    attr_reader :fields

    attr_accessor :id

    def initialize(options = {}, new_id = nil)
      @path   = @@path
      @fields = ::Hash.new
      init_fields options
      @id ||= new_id || self.class.uuid
    end

    def field_keys
      self.class.field_keys
    end

    def field_type
      self.class.field_type
    end

    def serialize
      attrs = field_keys.inject(::Hash.new) do |attrs, key|
        attrs[key] = fields[key]
        attrs
      end
      attrs[:id] = id
      attrs
    end

    def clone_value(val)
      if val.nil?
        nil
      else
        val.clone
      end
    end

    def init_fields(options = {})
      field_keys.each do |k|
        fields[k] = clone_value(self.class.default_field[k])
      end
      options.each do |k, v|
        fields[k] = clone_value(v)
      end
    end

    def remove
      self.class.collection.delete id
      self.class.update_file!
    end

    def update_attributes!(attrs)
      attrs.each do |key, value|
        fields[key] = clone_value(value)
      end
      save!
    end

    #
    # Persistence Methods
    #
    def save!
      self.class.collection[id] = serialize
      self.class.update_file!
    end

    def add_to_set(attrs)
      attrs.each do |key, value|
        fields[key].push value
        fields[key].uniq!
      end
      save!
    end

    def push(attrs)
      attrs.each do |key, value|
        case field_type[key].to_s
        when "Array"
          fields[key].push value
        when "Hash"
          fields[key].merge! value
        end
      end
      save!
    end

    def pull(attrs)
      attrs.each do |key, value|
        fields[key].delete value
      end
      save!
    end

    class << self

      # "Callback invoked whenever a subclass of the current class is created."
      # http://docs.ruby-lang.org/en/2.2.0/Class.html#method-i-inherited
      def inherited(child)
        load_file!
      end

      def yaml_document_hash
        $yaml_document_hash ||= ::Hash.new
      end

      def reset_yaml_document_hash!
        $yaml_document_hash = nil
      end

      def load_file!
        $yaml_document_hash = ::YAML.load(::File.read path) unless path.nil?
      end

      def set_path(new_path)
        @@path = new_path
        ::FileUtils.touch(path) unless ::File.exists?(path)
      end

      def path
        @@path
      end

      def update_file!
        ::File.write path, yaml_document_hash.to_yaml
        reset_yaml_document_hash!
        load_file!
      end

      #
      # Queries
      #
      def all
        Query.new self, collection
      end

      def exists?
        all.exists?
      end

      def count
        all.count
      end

      def find(id)
        if collection.has_key?(id)
          new collection[id], id
        else
          raise "ERROR: document not found"
        end
      end

      def find_by(cond)
        result = collection.select do |item_key|
          item = collection[item_key]
          cond.keys.all? do |key|
            cond[key] === item[key]
          end
        end

        if result.empty?
          raise "ERROR: document not found"
        else
          key, item = result.first
          new item, item[:id]
        end
      end

      def find_or_create_by(cond)
        if where(cond).exists?
          find_by cond
        else
          create cond
        end
      end

      def where(cond)
        Query.new(self, collection).find cond
      end

      def collection
        yaml_document_hash[self.name] ||= ::Hash.new
      end

      def field_keys
        @field_keys
      end

      def default_field
        @default_field
      end

      def field_type
        @field_type
      end

      def field(sym, options = {})
        @field_keys ||= ::Set.new
        @default_field ||= ::Hash.new
        @field_type ||= ::Hash.new

        default_field[sym] = options[:default] unless options[:default].nil?

        field_keys.add sym
        field_type[sym] = options[:type] || :String

        # define getter
        define_method sym do
          @fields[sym]
        end

        # define setter
        define_method "#{sym}=" do |v|
          @fields[sym] = v
        end
      end

      def uuid
        ::SecureRandom.uuid
      end

      def create(options = {})
        doc = new
        options.each {|k, v| doc.send "#{k}=", v }
        doc.id = uuid if doc.id.nil?
        collection[doc.id] = doc.serialize
        update_file!
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
