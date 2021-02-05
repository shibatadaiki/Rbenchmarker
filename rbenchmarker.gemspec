# frozen_string_literal: true

lib = File.expand_path('../lib/', __FILE__)
$:.unshift lib unless $:.include?(lib)
require_relative 'lib/rbenchmarker/version'

Gem::Specification.new do |spec|
  spec.name          = 'rbenchmarker'
  spec.version       = Rbenchmarker::VERSION
  spec.authors       = ['daiki shibata']
  spec.email         = ['shibatadaiki92@gmail.com']

  spec.summary       = 'Automatically log benchmarks for all methods'
  spec.description   = <<-EOF
    Rbenchmarker is a gem that allows you to automatically benchmark the execution time of a method defined in a Ruby class and module.
    Benchmark module (https://docs.ruby-lang.org/ja/latest/class/Benchmark.html) is used inside Rbenchmarker, and bm method is automatically applied to all target methods.
    Rbenchmarker does not necessarily require Ruby on Rails, but it is built on the assumption that Ruby on Rails will be used.
    There are some options that only work in the Ruby on Rails runtime environment.
  EOF
  spec.homepage      = 'https://github.com/shibatadaiki/Rbenchmarker'
  spec.license       = 'MIT'
  spec.required_ruby_version = Gem::Requirement.new('>= 2.3.0')

  spec.metadata['homepage_uri'] = spec.homepage
  spec.metadata['source_code_uri'] = 'https://github.com/shibatadaiki/Rbenchmarker/'
  spec.metadata['changelog_uri'] = 'https://github.com/shibatadaiki/Rbenchmarker/blob/master/CHANGELOG.md'
  
  spec.files = Dir['{lib}/**/*', 'CHANGELOG.md', 'MIT-LICENSE', 'README.md']
  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']
end
