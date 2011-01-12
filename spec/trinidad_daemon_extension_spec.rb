require File.expand_path(File.dirname(__FILE__) + '/spec_helper')
require 'optparse'

describe Trinidad::Extensions::DaemonServerExtension do
  subject { Trinidad::Extensions::DaemonServerExtension.new({}) }

  before(:each) do
    @tomcat = Trinidad::Tomcat::Tomcat.new
  end

  it "bypass the control to the daemon" do
    daemon = subject.configure(@tomcat)
    daemon.should_not be_nil
    daemon.should be_instance_of(org.jruby.trinidad.TrinidadDaemon)
  end

  it "uses a temporal directory to write the pid file by default" do
    daemon = subject.configure(@tomcat)
    daemon.pid_file.should =~ /trinidad.pid$/
  end

  it "can use a given pid file" do
    extension = Trinidad::Extensions::DaemonServerExtension.new(:pid_file => 'trinidad_pid.txt')
    daemon = extension.configure(@tomcat)
    daemon.pid_file.should =~ /trinidad_pid.txt$/
  end

  it "creates a default log info when it's not present" do
    log = subject.logger_options
    log['file'].should == 'log/trinidad.log'
    log['level'].should == 'INFO'
  end

  it "uses the log configuration provided when it's present" do
    extension = Trinidad::Extensions::DaemonServerExtension.new({
      :log => {
        :file => 'custom.log',
        :level => 'ALL'
      }
    })

    log = extension.logger_options
    log['file'].should == 'custom.log'
    log['level'].should == 'ALL'
  end

  it "uses the default level when it's not recognized" do
    extension = Trinidad::Extensions::DaemonServerExtension.new({
      :log => {
        :level => 'LEVEL'
      }
    })

    log = extension.logger_options
    log['file'].should == 'log/trinidad.log'
    log['level'].should == 'INFO'
  end

  it "allows to pass jvm arguments to the daemon" do
    extension = Trinidad::Extensions::DaemonServerExtension.new({
      :jvm_args => '-Xmx=2048m -XX:MaxPermSize=2048m'
    })

    extension.jvm_args.should have(2).arguments
  end
end

describe Trinidad::Extensions::DaemonOptionsExtension do
  it "allows to specify a command line option to run the daemon" do
    parser = OptionParser.new
    options = {}

    subject.configure(parser, options)
    parser.parse! '--daemonize /tmp/trinidad.pid'.split

    options[:extensions].keys.should include(:daemon)
    options[:extensions][:daemon].should include(:pid_file)
    options[:extensions][:daemon][:pid_file].should == '/tmp/trinidad.pid'
  end
end
