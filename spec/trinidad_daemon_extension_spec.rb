require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

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
end
