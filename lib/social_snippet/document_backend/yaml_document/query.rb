module SocialSnippet::DocumentBackend

  class YAMLDocument::Query

    attr_reader :document_class
    attr_reader :collection

    def initialize(new_document_class, new_collection)
      @document_class = new_document_class
      @collection = new_collection
    end

    def exists?
      collection.size > 0
    end

    def find(cond)
      new_collection = collection.select do |item_id, item|
        cond.all? {|k, _| cond[k] === item[k] }
      end
      self.class.new document_class, new_collection
    end

    def count
      collection.length
    end

    def enum
      collection.map do |_, item|
        document_class.new item
      end
    end

    def each(&block)
      enum.each &block
    end

    def map(&block)
      enum.map &block
    end

  end

end

