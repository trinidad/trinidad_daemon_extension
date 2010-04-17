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

  it "allows to specify a command line option to run the daemon" do
    extension = Trinidad::Extensions::DaemonOptionsExtension.new
    parser = OptionParser.new
    options = {}
    
    extension.configure(parser, options)
    parser.parse! '-d /tmp/trinidad.pid'.split

    options[:extensions].keys.should include(:daemon)
    options[:extensions][:daemon].should include(:pid_file)
    options[:extensions][:daemon][:pid_file].should == '/tmp/trinidad.pid'
  end
end
