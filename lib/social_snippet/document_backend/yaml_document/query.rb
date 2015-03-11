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
      new_collection = collection.select do |item_id, item|
        cond.all? {|k, _| cond[k] === item[k] }
      end
      self.class.new new_collection
    end

    def count
      collection.length
    end

  end

end

