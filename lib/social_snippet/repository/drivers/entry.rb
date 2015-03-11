class ::SocialSnippet::Repository::Drivers::Entry

  attr_reader :path
  attr_reader :data

  def initialize(new_path, new_data = nil)
    @path = new_path
    @data = new_data
  end

end
