require "spec_helper"

describe ::SocialSnippet::DocumentBackend::YAMLDocument, :current => true do

  before { ::FileUtils.mkdir_p "/path/to" }
  before { ::SocialSnippet::DocumentBackend::YAMLDocument.set_path "/path/to/document.yml" }
  before { $yaml_document_hash = nil } # reset hash

  describe "#load_file!" do

    context "prepare yaml" do

      before do
        ::File.write "/path/to/document.yml", {
          "TestDocument" => {
            "item1" => {
              "name" => "item-1",
              "values" => [
                "val1-1",
                "val1-2",
                "val1-3",
              ],
              "info" => {
                "hello" => "world",
              },
            },
            "item2" => {
              "name" => "item-2",
              "values" => [
                "val1-1",
                "val1-2",
                "val1-3",
              ],
              "info" => {
                "foo" => "bar",
              },
            },
          },
        }.to_yaml
      end

      context "prepare class" do

        let(:doc_class) do
          ::Class.new(::SocialSnippet::DocumentBackend::YAMLDocument) do
            field :name, :type => String
            field :values, :type => Array
            field :info, :type => Hash

            def self.name
              "TestDocument"
            end
          end
        end

        context "find item1" do
          let(:item) { doc_class.find "item1" }
          it { expect(item.name).to eq "item1" }
          it { expect(item.values.length).to 3 }
          it { expect(item.values).to include "val1-1" }
          it { expect(item.values).to include "val1-2" }
          it { expect(item.values).to include "val1-3" }
          it { expect(item.info["hello"]).to eq "world" }
        end

        context "find item2" do
          let(:item) { doc_class.find "item2" }
          it { expect(item.name).to eq "item2" }
          it { expect(item.values.length).to 3 }
          it { expect(item.values).to include "val2-1" }
          it { expect(item.values).to include "val2-2" }
          it { expect(item.values).to include "val2-3" }
          it { expect(item.info["foo"]).to eq "bar" }
        end

        context "remove item2" do
          before { doc_class.find("item2").remove }
          context "find item2" do
            subject do
              lambda { doc_class.find "item2" }
            end
            it { should raise_error }
          end
          context "find item1" do
            let(:item) { doc_class.find("item1") }
            it { expect(item.name).to eq "item1" }
          end
        end # remove item2

      end

    end # prepare yaml

  end #load_file!

end # ::SocialSnippet::DocumentBackend::YAMLDocument

