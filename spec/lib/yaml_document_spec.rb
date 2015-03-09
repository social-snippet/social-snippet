require "spec_helper"

describe ::SocialSnippet::DocumentBackend::YAMLDocument do

  context "activate" do

    before { ::SocialSnippet::DocumentBackend::YAMLDocument.activate! }

    include_context :TestDocument

  end

end

