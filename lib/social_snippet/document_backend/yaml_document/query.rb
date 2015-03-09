module SocialSnippet::DocumentBackend

  class YAMLDocument::Query

    attr_reader :collection

    def initialize(new_collection)
      @collection = new_collection
    end

    def exists?
      collection.size > 0
    end

    def find(cond)
      collection.select do |item_id, item|
        cond.any? {|k, _| cond[k] === item[k] }
      end
      self.class.new collection
    end

    def count
      collection.length
    end

  end

end

