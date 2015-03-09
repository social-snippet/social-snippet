require "spec_helper"

describe ::SocialSnippet::DocumentBackend::YAMLDocument do

  context "set yaml path" do

    let(:document_path) { "/path/to/document.yml" }

    before do
      ::FileUtils.mkdir_p "/path/to"
      $yaml_document_hash = nil
      ::FileUtils.rm document_path if ::File.exists?(document_path)
      ::SocialSnippet::DocumentBackend::YAMLDocument.set_path document_path
    end

    context "activate" do

      before { ::SocialSnippet::DocumentBackend::YAMLDocument.activate! }

      include_context :TestDocument

    end

  end

end

