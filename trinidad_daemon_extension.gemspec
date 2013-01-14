# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require 'trinidad_daemon_extension/version'

Gem::Specification.new do |s|
  s.name              = 'trinidad_daemon_extension'
  s.version           = Trinidad::Extensions::Daemon::VERSION
  s.rubyforge_project = 'trinidad_daemon_extension'
  
  s.summary     = "Daemon extension for Trinidad"
  s.description = "Trinidad extension to run the Apache Tomcat server as a daemon (for Unix only)."
  
  s.authors  = ["David Calavera"]
  s.email    = 'calavera@apache.org'
  s.homepage = 'http://github.com/trinidad/trinidad_daemon_extension'
  s.rdoc_options = ["--charset=UTF-8"]
  s.extra_rdoc_files = %w[README.md LICENSE]
  
  s.require_paths = %w[lib]
  
  s.add_dependency('trinidad', ">= 1.3.5")
  
  s.add_development_dependency('rspec', '~> 2.10')
  s.add_development_dependency('mocha', '>= 0.11')
  
  s.files = `git ls-files`.split("\n").sort.
    reject { |file| file =~ /^\./ }.
    reject { |file| file =~ /^(rdoc|pkg|src|git-hooks)/ }
  
  s.test_files = s.files.select { |path| path =~ /^spec\/.*_spec\.rb/ }
end
