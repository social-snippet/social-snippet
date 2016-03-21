# Social Snippet

[![Gem Version](https://img.shields.io/gem/v/social_snippet.svg?style=flat-square)](https://rubygems.org/gems/social_snippet)
[![Build Status](https://img.shields.io/travis/social-snippet/social-snippet.svg?style=flat-square)](https://travis-ci.org/social-snippet/social-snippet)
[![Code Climate](https://img.shields.io/codeclimate/github/social-snippet/social-snippet.svg?style=flat-square)](https://codeclimate.com/github/social-snippet/social-snippet)
[![Test Coverage](https://img.shields.io/codeclimate/coverage/github/social-snippet/social-snippet.svg?style=flat-square)](https://codeclimate.com/github/social-snippet/social-snippet)
[![API Doc](http://img.shields.io/badge/RubyDocs-API-green.svg?style=flat-square)](http://www.rubydoc.info/github/social-snippet/social-snippet)
[![Dependencies Status](https://img.shields.io/gemnasium/social-snippet/social-snippet.svg?style=flat-square)](https://gemnasium.com/social-snippet/social-snippet)

### 1. Quick Start for the busy person

How to install social snippet
You can install the social-snippet core system by typing the command as follow:

```
$ gem install social_snippet
```

...then, you should install the editor plugin (e.g. social_snippet.vim).

### 2. How it works

#### The Command-line Interface

The social_snippet gem provides the command-line interface to manage and use the snippet libraries. For example, you can search the libraries by running `$ sspm search {keyword}` command, and install them by running `$ sspm install {name}` command. The `sspm-install` command can resolve dependencies between the libraries, so if the system found a missing required library on the installation of some library, it is also installed to the your system automatically.

#### @snip / @snippet annotation tags

To insert snippet texts, the social-snippet's core system replaces the annotated comment lines with the code specified on the comments.

#### Basic Syntax

##### (1) Before insert a snippet

// @snip < {repo-name} # {repo-version} : {file-path} >

##### (2) After insert a snippet

// @snippet < {repo-name} # {repo-version} : {file-path} >
{the snippet source code}

##### Description

###### {repo-name}

This is the name of repository added in the social-snippet registry system. You can install the repository by running $ sspm install {repo-name} command.

## Requirements

We recommend to use the latest versions of Ruby and Git.

* Ruby >= 1.9.3
* Git

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'social_snippet'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install social_snippet

## Usage

TODO: Write usage instructions here

## Contributing

1. Fork it ( https://github.com/[my-github-username]/social_snippet/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
