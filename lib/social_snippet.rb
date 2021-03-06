require "tsort"
require "logger"
require "highline"
require "pathname"
require "json"
require "yaml"
require "version_sorter"
require "rest_client"
require "optparse"
require "uri"
require "wisper"
require "securerandom"
require "css_parser"

module SocialSnippet; end
require_relative "social_snippet/core"
require_relative "social_snippet/version"
require_relative "social_snippet/tag"
require_relative "social_snippet/tag_parser"
require_relative "social_snippet/config"
require_relative "social_snippet/repository"
require_relative "social_snippet/context"
require_relative "social_snippet/snippet"
require_relative "social_snippet/inserter"
require_relative "social_snippet/resolvers"
require_relative "social_snippet/registry"
require_relative "social_snippet/command_line"
require_relative "social_snippet/logger"
require_relative "social_snippet/api"
require_relative "social_snippet/tsortable_hash"
require_relative "social_snippet/storage_backend"
require_relative "social_snippet/storage"
require_relative "social_snippet/document_backend"
require_relative "social_snippet/document"

# supports
require "social_snippet/supports/git"

# use file system as default storage backend
SocialSnippet::StorageBackend::FileSystemStorage.activate!
# use yaml as default document backend
SocialSnippet::DocumentBackend::YAMLDocument.activate!

