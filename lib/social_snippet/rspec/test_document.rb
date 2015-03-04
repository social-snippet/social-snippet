RSpec.configure do

  shared_context :TestDocument do

    class TestDocument < ::SocialSnippet::Document
      field :field_string, :type => String
      field :field_array, :type => Array, :default => ::Array.new
      field :field_hash, :type => Hash, :default => ::Hash.new
    end

    describe "test field" do

      let(:doc) do
        TestDocument.new
      end

      context "doc.field_string = test" do
        before { doc.field_string = "test" }
        it { expect(doc.field_string).to eq "test" }
      end

      context "doc.field_array.push item" do
        before { doc.field_array.push "item" }
        it { expect(doc.field_array).to include "item" }
      end

      context "doc.field_hash[key] = value" do
        before { doc.field_hash["key"] = "value" }
        it { expect(doc.field_hash["key"]).to eq "value" }
      end

    end # test field

    describe "test persistence" do

      context "create item" do

        before do
          item = TestDocument.create(:id => "item")
          item.field_string = "this is string"
          item.field_array.push "this is array"
          item.field_hash["key"] = "this is hash"
          item.save!
        end

        context "check existance" do
          subject { TestDocument.where(:id => "item").exists? }
          it { should be_truthy }
        end

        context "find item" do
          subject { TestDocument.find "item" }
          it { expect(subject.field_string).to eq "this is string" }
          it { expect(subject.field_array).to include "this is array" }
          it { expect(subject.field_hash["key"]).to eq "this is hash" }
        end

        context "remove item" do
          before { TestDocument.find("item").remove }
          context "re-find item" do
            subject { TestDocument.where(:id => "item").exists? }
            it { should be_falsey }
          end
        end

      end # create item

    end # test persistence

  end # [shared] TestDocument

end

