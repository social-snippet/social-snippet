RSpec.configure do

  shared_context :TestDocument do

    class TestDocument1 < ::SocialSnippet::Document
      field :field_string, :type => String
      field :field_array, :type => Array, :default => ::Array.new
      field :field_hash, :type => Hash, :default => ::Hash.new
    end

    class TestDocument2 < ::SocialSnippet::Document
      field :field_string, :type => String
      field :field_array, :type => Array, :default => ::Array.new
      field :field_hash, :type => Hash, :default => ::Hash.new
    end

    describe "#find_by" do

      context "find_or_create_by :field_string => abc" do

        before do
          doc = TestDocument1.find_or_create_by(:field_string => "abc")
          doc.field_array.push "val1"
          doc.field_array.push "val2"
          doc.field_array.push "val3"
          doc.field_hash["key"] = "val"
          doc.save!
        end

        context "find_by :field_string => abc" do
          let(:item) { TestDocument1.find_by :field_string => "abc" }
          it { expect(item.field_string).to eq "abc" }
          it { expect(item.field_array.length).to eq 3 }
          it { expect(item.field_array).to include "val1" }
          it { expect(item.field_array).to include "val2" }
          it { expect(item.field_array).to include "val3" }
          it { expect(item.field_hash["key"]).to include "val" }
        end

        context "find_by :field_string => not_found" do
          subject do
            lambda { TestDocument1.find_by :field_string => "not_found" }
          end
          it { should raise_error }
        end

      end

    end #find_by

    describe "test field" do

      let(:doc) do
        TestDocument1.new
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
          item = TestDocument1.create(:id => "item")
          item.field_string = "this is string"
          item.field_array.push "this is array"
          item.field_hash["key"] = "this is hash"
          item.save!
        end

        context "check existance" do
          context "TestDocument1.where(:id => item).exists?" do
            subject { TestDocument1.where(:id => "item").exists? }
            it { should be_truthy }
          end
          context "TestDocument2.where(:id => item).exists?" do
            subject { TestDocument2.where(:id => "item").exists? }
            it { should be_falsey }
          end
        end

        context "find item" do
          context "in document-1" do
            subject { TestDocument1.find "item" }
            it { expect(subject.field_string).to eq "this is string" }
            it { expect(subject.field_array).to include "this is array" }
            it { expect(subject.field_hash["key"]).to eq "this is hash" }
          end
          context "in document-2" do
            example do
              expect { TestDocument2.find "item" }.to raise_error
            end
          end
        end

        context "remove item" do
          before { TestDocument1.find("item").remove }
          context "re-find item" do
            subject { TestDocument1.where(:id => "item").exists? }
            it { should be_falsey }
          end
        end

      end # create item

    end # test persistence

  end # [shared] TestDocument

end

