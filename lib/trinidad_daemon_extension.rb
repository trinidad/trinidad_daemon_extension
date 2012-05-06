require 'trinidad'
require 'trinidad/jars'
require 'trinidad/extensions'

require 'trinidad_daemon_extension/jars'
require 'trinidad_daemon_extension/tomcat_wrapper'
require 'trinidad_daemon_extension/version'

module Trinidad
  module Extensions
    class DaemonServerExtension < ServerExtension
      def configure(tomcat)
        Trinidad::Extensions::Daemon::TomcatWrapper.new(tomcat, pid_file, jvm_args)
      end

      def override_tomcat?; true; end

      def pid_file
        @options[:pid_file]
      end
      
      def jvm_args
        @options[:jvm_args] ? @options[:jvm_args].split : []
      end
    end

    class DaemonOptionsExtension < OptionsExtension
      def configure(parser, default_options)
        message = 'run Trinidad as a daemon, PID_FILE defaults to ENV[TMPDIR]/trinidad.pid'
        parser.on('--daemonize', '--daemonize [PID_FILE]', message) do |pid|
          extensions = default_options[:extensions] || {}
          extensions[:daemon] = { :pid_file => pid }
          default_options[:extensions] = extensions
        end
      end
    end
  end
end
