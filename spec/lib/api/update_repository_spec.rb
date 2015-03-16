require "spec_helper"

describe ::SocialSnippet::Api::UpdateRepositoryApi do

  describe "has dependencies" do

    context "prepare stubs" do

      let(:graph_algo_url) { "dummy://driver.test/user/graph-algo" }
      let(:adjacent_list_url) { "dummy://driver.test/user/adjacent-list" }
      let(:graph_interface_url) { "dummy://driver.test/user/graph-interface" }

      before do
        allow(fake_core.repo_manager).to receive(:install).with(graph_interface_url, "1.2.3", kind_of(::Hash)) do
          repo = ::SocialSnippet::Repository::Models::Repository.find_or_create_by(:name => "graph-interface")
          repo.update_attributes! :url => graph_interface_url
          repo.add_ref "1.2.3", "rev-1.2.3"
          pkg = ::SocialSnippet::Repository::Models::Package.create(
            :repo_name => "graph-interface",
            :rev_hash => "rev-1.2.3",
          )
          pkg.add_file "snippet.json", {}.to_json
          pkg
        end
        allow(fake_core.api).to receive(:resolve_name_by_registry).with("graph-interface") do
          graph_interface_url
        end
      end

      before do
        allow(fake_core.repo_manager).to receive(:install).with(adjacent_list_url, "9.9.9", kind_of(::Hash)) do
          repo = ::SocialSnippet::Repository::Models::Repository.find_or_create_by(:name => "adjacent-list")
          repo.update_attributes! :url => adjacent_list_url
          repo.add_ref "9.9.9", "rev-9.9.9"
          pkg = ::SocialSnippet::Repository::Models::Package.create(
            :repo_name => "adjacent-list",
            :rev_hash => "rev-9.9.9",
          )
          pkg.add_file "snippet.json", {}.to_json
          pkg.add_dependency "graph-interface", "1.2.3"
          pkg
        end
        allow(fake_core.api).to receive(:resolve_name_by_registry).with("adjacent-list") do
          adjacent_list_url
        end
      end

      before do
        allow(fake_core.repo_manager).to receive(:install).with(graph_algo_url, "1.0.0", kind_of(::Hash)) do
          repo = ::SocialSnippet::Repository::Models::Repository.find_or_create_by(:name => "graph-algo")
          repo.update_attributes! :url => graph_algo_url
          repo.add_ref "1.0.0", "rev-1.0.0"
          repo.add_package "1.0.0"
          pkg = ::SocialSnippet::Repository::Models::Package.create(
            :repo_name => "graph-algo",
            :rev_hash => "rev-1.0.0",
          )
          pkg.add_file "snippet.json", {}.to_json
          pkg
        end
        allow(fake_core.api).to receive(:resolve_name_by_registry).with("graph-algo") do
          graph_algo_url
        end
      end

      before { fake_core.api.install_repository graph_algo_url, "1.0.0" }
      it { expect(fake_core.repo_manager.exists? "graph-algo", "1.0.0").to be_truthy }
      it { expect(fake_core.repo_manager.exists? "adjacent-list", "9.9.9").to be_falsey }
      it { expect(fake_core.repo_manager.exists? "graph-interface", "1.2.3").to be_falsey}

      context "prepare update for graph-algo" do

        class FakeDriverGraphAlgo < ::SocialSnippet::Repository::Drivers::DriverBase
          def fetch; end

          def snippet_json
            {
              "name" => "graph-algo",
              "dependencies" => {
                "adjacent-list" => "9.9.9",
              },
            }
          end

          def rev_hash(ref)
            if refs.include?(ref)
              "rev-#{ref}"
            else
              raise "error"
            end
          end

          def each_directory(ref); end
          def each_content(ref, &block)
            [
              ::SocialSnippet::Repository::Drivers::Entry.new("snippet.json", snippet_json.to_json)
            ].each(&block)
          end
          def each_ref(&block)
            refs.each &block
          end

          def refs
            ["1.0.0", "1.0.1"]
          end

          def self.target_url?(url)
            "dummy" === ::URI.parse(url).scheme
          end
        end # class FakeDriverGraphAlgo

        before do
          fake_core.repo_factory.reset_drivers
          fake_core.repo_factory.add_driver FakeDriverGraphAlgo
        end

        context "update graph-algo" do
          before { fake_core.api.update_repository "graph-algo" }
          it { expect(fake_core.repo_manager.exists? "graph-algo", "1.0.0").to be_truthy }
          it { expect(fake_core.repo_manager.exists? "graph-algo", "1.0.1").to be_truthy }
          it { expect(fake_core.repo_manager.exists? "adjacent-list", "9.9.9").to be_truthy }
          it { expect(fake_core.repo_manager.exists? "graph-interface", "1.2.3").to be_truthy }
        end
      end

    end

  end

  context "prepare driver" do

    class FakeDriverUpdateTest < ::SocialSnippet::Repository::Drivers::DriverBase
      def fetch; end

      def snippet_json
        {
          "name" => "my-repo"
        }
      end

      def rev_hash(ref)
        if refs.include?(ref)
          "rev-#{ref}"
        else
          raise "error"
        end
      end

      def each_directory(ref); end
      def each_content(ref, &block)
        [
          ::SocialSnippet::Repository::Drivers::Entry.new("snippet.json", snippet_json.to_json),
        ].each(&block)
      end
      def each_ref(&block)
        refs.each &block
      end

      def refs
        self.class.refs
      end

      def self.refs
        @refs ||= new_refs
      end

      def self.new_refs
        ["1.0.0"]
      end

      def self.add_ref(ref)
        @refs.push ref
      end

      def self.target_url?(url)
        "dummy" === ::URI.parse(url).scheme
      end
    end # class FakeDriverUpdateTest

    before do
      fake_core.repo_factory.reset_drivers
      fake_core.repo_factory.add_driver FakeDriverUpdateTest
    end

    context "install my-repo#1.0.0" do
      before { fake_core.api.install_repository "dummy://driver.test/user/my-repo", "1.0.0" }
      it { expect(fake_core.repo_manager.exists? "my-repo", "1.0.0").to be_truthy }
      it { expect(fake_core.repo_manager.exists? "my-repo", "1.0.1").to be_falsey }
      context "add 1.0.1" do
        before { FakeDriverUpdateTest.add_ref "1.0.1" }
        context "update my-repo" do
          before { fake_core.api.update_repository "my-repo" }
          it { expect(fake_core.repo_manager.exists? "my-repo", "1.0.0").to be_truthy }
          it { expect(fake_core.repo_manager.exists? "my-repo", "1.0.1").to be_truthy }
        end
      end
    end # install my-repo#1.0.0

  end # prepare driver

end # ::SocialSnippet::Api::UpdateRepositoryApi

