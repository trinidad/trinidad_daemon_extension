require 'rubygems'
gem 'trinidad_jars'
require 'trinidad/extensions'
require 'trinidad/jars'

require File.expand_path('../../trinidad-libs/akuma', __FILE__)
require File.expand_path('../../trinidad-libs/trinidad-daemon-extension', __FILE__)

module Trinidad
  module Extensions
    class DaemonServerExtension < ServerExtension
      VERSION = '0.1.0'

      def configure(tomcat)
        org.jruby.trinidad.TrinidadDaemon.new(tomcat, @options[:pid_file])
      end
    end
  end
end
