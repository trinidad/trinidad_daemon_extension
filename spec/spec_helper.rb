begin
  require 'rspec'
rescue LoadError
  require 'rubygems'
  gem 'rspec'
  require 'rspec'
end

require 'mocha'

RSpec.configure do |config|
  config.mock_with :mocha
end

require 'java'

$:.unshift(File.dirname(__FILE__) + '/../lib')
require 'trinidad_daemon_extension'
