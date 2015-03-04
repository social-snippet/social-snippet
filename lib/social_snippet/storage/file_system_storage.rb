module SocialSnippet::Storage

  class FileSystemStorage < StorageBase

    def read(path)
      ::File.read path
    end

    def write(path, data)
      ::File.write path, data
    end

    def touch(path)
      ::FileUtils.touch path
    end

    def glob(glob_path)
      ::Dir.glob glob_path
    end

    def exists?(path)
      ::File.exists? path
    end

    def file?(path)
      ::File.file? path
    end

    def directory?(path)
      ::File.directory? path
    end

    def mkdir_p(path)
      ::FileUtils.mkdir_p path
    end

  end

end

