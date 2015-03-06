require "spec_helper"

describe ::SocialSnippet::DocumentBackend::YAMLDocument do

  context "set yaml path" do

    before do
      ::FileUtils.mkdir_p "/path/to"
      ::SocialSnippet::DocumentBackend::YAMLDocument.set_path "/path/to/document.yml"
    end

    context "activate" do

      before { ::SocialSnippet::DocumentBackend::YAMLDocument.activate! }

      include_context :TestDocument

    end

  end

end

