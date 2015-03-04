module SocialSnippet::DocumentBackend

  class YAMLDocument

    def self.yaml_path(new_path)
      @path = new_path
    end

    def self.field(sym, options = {})
      fields ||= {}

      # set default value
      fields[sym] = options[:default] unless options[:default].nil?

      # define getter
      define_method sym.to_s do
        fields[sym]
      end

      # define setter
      define_method "#{sym.to_s}=" do |v|
        fields[sym] = v
      end
    end

    def self.create(options = {})
    end

    def self.activate!
      ::SocialSnippet.class_eval do
        remove_const :Document
        const_set :Document, YAMLDocument
      end
    end

  end

end
