# coding: utf-8
# frozen_string_literal: true
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'arborist/version'

Gem::Specification.new do |spec|
  spec.name          = 'arborist-rails'
  spec.version       = Arborist::VERSION
  spec.authors       = ['Adam Cuppy']
  spec.email         = ['adam@codingzeal.com']
  spec.summary       = 'Framework for working with data migrations and seeds
    in a Rails application'
  spec.homepage      = 'https://github.com/acuppy/arborist'
  spec.license       = 'MIT'

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ['lib']

  spec.add_dependency 'activerecord', '>= 3.2.0'
  spec.add_development_dependency 'bundler', '~> 1.7'
  spec.add_development_dependency 'rake', '~> 10.0'
  spec.add_development_dependency 'rspec'
  spec.add_development_dependency 'sqlite3'
  spec.add_development_dependency 'pry-byebug'
end
