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

    describe "#add_to_set" do

      context "create item" do

        let(:item) { TestDocument2.create }
        it { expect(item.field_array).to be_empty }

        context "add_to_set value" do

          before { item.add_to_set :field_array => "value" }
          it { expect(item.field_array.length).to eq 1 }
          it { expect(item.field_array).to include "value" }

          context "add_to_set new_value" do

            before { item.add_to_set :field_array => "new-value" }
            it { expect(item.field_array.length).to eq 2 }
            it { expect(item.field_array).to include "value" }
            it { expect(item.field_array).to include "new-value" }

            context "add_to_set value (duplicated value)" do

              before { item.add_to_set :field_array => "value" }
              it { expect(item.field_array.length).to eq 2 }
              it { expect(item.field_array).to include "value" }
              it { expect(item.field_array).to include "new-value" }

              context "find item.id" do

                let(:found_item) { TestDocument2.find(item.id) }
                it { expect(item.field_array.length).to eq 2 }
                it { expect(item.field_array).to include "value" }
                it { expect(item.field_array).to include "new-value" }

              end

            end

          end

        end

      end

    end #add_to_set

    describe "#update_attributes!" do

      context "create item" do
        let(:item) { TestDocument1.create :field_string => "value" }
        subject { item.field_string }
        it { should eq "value" }
        context "find item.id" do
          subject { TestDocument1.find item.id }
          it { expect(subject.field_string).to eq "value" }
        end
        context "item.update_attributes! field_string => new-value" do
          before { item.update_attributes! :field_string => "new-value" }
          it { should eq "new-value" }
          context "find item.id" do
            subject { TestDocument1.find item.id }
            it { expect(subject.field_string).to eq "new-value" }
          end
        end
      end

    end

    describe "#push" do

      context "create item" do

        let(:item) { TestDocument1.create }
        it { expect(item.field_array).to be_empty }

        context "push item" do

          before { item.push :field_array => "val" }
          it { expect(item.field_array).to_not be_empty }
          it { expect(item.field_array).to include "val" }

          context "pull item" do

            before { item.pull :field_array => "val" }
            it { expect(item.field_array).to be_empty }

          end

        end

      end

    end #push

    describe "#count" do

      subject { TestDocument1.count }
      it { should eq 0 }

      context "create a item" do

        before { TestDocument1.create(:field_string => "item") }
        it { should eq 1 }

        context "find_or_create_by item" do

          before { TestDocument1.find_or_create_by(:field_string => "item") }
          it { should eq 1 }

          context "create another item" do
            before { TestDocument1.create(:field_string => "item") }
            it { should eq 2 }
          end

        end

      end

    end

    describe "#exists?" do

      subject { TestDocument1.exists? }
      it { should be_falsey }

      context "TestDocument2.exists?" do
        subject { TestDocument2.exists? }
        it { should be_falsey }
      end

      context "create a item" do

        before { TestDocument1.create(:field_string => "item1") }
        it { should be_truthy }

        context "TestDocument2.exists?" do
          subject { TestDocument2.exists? }
          it { should be_falsey }
        end

      end # create a item

    end #exists?

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

