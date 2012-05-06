require 'java'

trinidad_libs = 
  defined?(Trinidad::Extensions::Daemon::TRINIDAD_LIBS) ?
  Trinidad::Extensions::Daemon::TRINIDAD_LIBS : 
  File.expand_path('../../../trinidad-libs', __FILE__)

require File.join(trinidad_libs, 'akuma.jar')
require File.join(trinidad_libs, 'jna.jar')
