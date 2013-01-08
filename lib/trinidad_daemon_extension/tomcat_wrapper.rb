require 'tmpdir'

module Trinidad
  module Extensions
    module Daemon
      class TomcatWrapper
        
        attr_reader :pid_file, :jvm_args
        
        def initialize(tomcat, pid_file = nil, jvm_args = nil)
          @tomcat = tomcat
          # Dir.tmpdir allows overriding /tmp location from ENV
          pid_file ||= File.join(Dir.tmpdir, 'trinidad.pid')
          @pid_file = java.io.File.new(pid_file).getAbsolutePath
          @jvm_args = jvm_args
        end
        
        def server
          @tomcat.server # getServer()
        end

        def service
          @tomcat.service # getService()
        end

        def engine
          @tomcat.engine # getEngine()
        end

        def host
          @tomcat.host # getHost()
        end
        
        def start
          daemon = com.sun.akuma.Daemon::WithoutChdir.new
          if daemon.isDaemonized
            pid = com.sun.akuma.CLibrary::LIBC.getpid
            puts "Starting Trinidad as a daemon"
            puts "To stop it, kill -s SIGINT #{pid}"
            daemon.init(pid_file)
          else
            daemon.daemonize(configure_jvm_args)
            java.lang.System.exit(0)
          end
          @tomcat.start
          @tomcat.server.await
        rescue java.lang.Exception => e
          java.lang.System.err.println("Error daemonizing Trinidad: " + e.getMessage())
          e.printStackTrace(java.lang.System.err)
          java.lang.System.exit(1)
        end
        
        def stop
          @tomcat.stop
        end
        
        def respond_to?(name)
          super || @tomcat.respond_to?(name)
        end
        
        def method_missing(name, *args, &block)
          if @tomcat.respond_to?(name)
            @tomcat.send(name, *args, &block)
          else
            super
          end
        end
        
        private
        
          def configure_jvm_args
            args = com.sun.akuma.JavaVMArguments.new
            com.sun.akuma.JavaVMArguments.current.each do |arg|
              if arg.to_java.startsWith("-Xbootclasspath")
                # add here the custom arguments, otherwhise are added after
                # trinidad script and break optionParser
                jvm_args.each { |custom| args.add(custom) }
              end
              # I don't understand this hack but without it the daemon goes off, 
              # could be others
              args.add(arg) unless arg.to_java.endsWith("java")
            end
            args
          end
        
      end
    end
  end
end
