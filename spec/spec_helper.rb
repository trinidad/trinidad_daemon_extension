begin
  require 'rspec'
rescue LoadError => e
  require('rubygems') && retry
  raise e
end
begin
  require 'mocha/api'
rescue LoadError
  require 'mocha'
end

RSpec.configure do |config|
  config.mock_with :mocha
end

$:.unshift(File.dirname(__FILE__) + '/../lib')
require 'trinidad_daemon_extension'
