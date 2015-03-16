require "spec_helper"

describe ::SocialSnippet::Api::UpdateRepositoryApi, :current => true do

  describe "has dependencies" do

    context "prepare stubs" do

      let(:graph_algo_url) { "dummy://driver.test/user/graph-algo" }
      let(:adjacent_list_url) { "dummy://driver.test/user/adjacent-list" }
      let(:graph_interface_url) { "dummy://driver.test/user/graph-interface" }

      before do
        allow(fake_core.repo_manager).to receive(:install).with(graph_interface_url, "1.2.3", kind_of(::Hash)) do
          repo = ::SocialSnippet::Repository::Models::Repository.find_or_create_by(:name => "graph-algo")
          pkg = ::SocialSnippet::Repository::Models::Package.new
          pkg
        end
        allow(fake_core.api).to receive(:resolve_name_by_registry).with("graph-interface") do
          graph_interface_url
        end
      end

      before do
        allow(fake_core.repo_manager).to receive(:install).with(adjacent_list_url, "9.9.9", kind_of(::Hash)) do
          repo = ::SocialSnippet::Repository::Models::Repository.find_or_create_by(:name => "graph-algo")
          pkg = ::SocialSnippet::Repository::Models::Package.new
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
          pkg = ::SocialSnippet::Repository::Models::Package.new
          pkg.add_dependency "adjacent-list", "9.9.9"
          pkg
        end
        allow(fake_core.api).to receive(:resolve_name_by_registry).with("graph-algo") do
          graph_algo_url
        end
      end

      before { fake_core.api.install_repository graph_algo_url, "1.0.0" }
      it { expect(fake_core.repo_manager.exists? "my-repo", "1.0.0") }
      it { expect(fake_core.repo_manager.exists? "adjacent-list", "9.9.9") }
      it { expect(fake_core.repo_manager.exists? "graph-interface", "1.2.3") }

    end

  end

  context "prepare driver" do

    class FakeDriver < ::SocialSnippet::Repository::Drivers::DriverBase
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
      def each_content(ref); end
      def each_ref(&block)
        refs.each &block
      end

      @@refs = ["1.0.0"]

      def refs
        @@refs
      end

      def self.add_ref(ref)
        @@refs.push ref
      end

      def self.target_url?(url)
        "dummy" === ::URI.parse(url).scheme
      end
    end # class FakeDriver

    before do
      fake_core.repo_factory.reset_drivers
      fake_core.repo_factory.add_driver FakeDriver
    end

    context "install my-repo#1.0.0" do
      before { fake_core.api.install_repository "dummy://driver.test/user/my-repo", "1.0.0" }
      it { expect(fake_core.repo_manager.exists? "my-repo", "1.0.0").to be_truthy }
      it { expect(fake_core.repo_manager.exists? "my-repo", "1.0.1").to be_falsey }
      context "add 1.0.1" do
        before { FakeDriver.add_ref "1.0.1" }
        context "update my-repo" do
          before { fake_core.api.update_repository "my-repo" }
          it { expect(fake_core.repo_manager.exists? "my-repo", "1.0.0").to be_truthy }
          it { expect(fake_core.repo_manager.exists? "my-repo", "1.0.1").to be_truthy }
        end
      end
    end # install my-repo#1.0.0

  end # prepare driver

end # ::SocialSnippet::Api::UpdateRepositoryApi

