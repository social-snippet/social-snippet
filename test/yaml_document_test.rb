require "spec_helper"

describe ::SocialSnippet::DocumentBackend::YAMLDocument, :current => true do

  before { ::FileUtils.mkdir_p "/path/to" }
  before { ::SocialSnippet::DocumentBackend::YAMLDocument.set_path "/path/to/document.yml" }
  before { $yaml_document_hash = nil } # reset hash

  describe "#load_file!" do

    context "prepare yaml" do

      before do
        ::File.write "/path/to/document.yml", {
          "testdocument" => {
            "item1" => {
              "name" => "item-1",
            },
            "item2" => {
              "name" => "item-2",
            },
          },
        }.to_yaml
      end

      context "prepare class" do

        let(:klazz) do
          class TestDocument < ::SocialSnippet::DocumentBackend::YAMLDocument
            field :name, :type => String
          end
          TestDocument
        end

        context "find item1" do
          let(:item) { klazz.find "item1" }
          it { expect(item.name).to eq "item1" }
        end

      end

    end # prepare yaml

  end #load_file!

end # ::SocialSnippet::DocumentBackend::YAMLDocument

