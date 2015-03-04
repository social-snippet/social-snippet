module SocialSnippet::StorageBackend

  class StorageBase

    def read(path)
      raise "not implemented"
    end

    def write(path, data)
      raise "not implemented"
    end

    def glob(glob_path)
      raise "not implemented"
    end

    def exists?(path)
      raise "not implemented"
    end

    def file?(path)
      raise "not implemented"
    end

    def directory?(path)
      raise "not implemented"
    end

    def mkdir_p(path)
      raise "not implemented"
    end

  end

end
