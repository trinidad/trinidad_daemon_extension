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
    daemon.should be_instance_of(Trinidad::Extensions::Daemon::TomcatWrapper)
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

class Java::OrgApacheCatalinaStartup::Tomcat
  
  field_reader :basedir # only setBaseDir
  field_reader :port, :hostname # only setters
  
end

describe Trinidad::Extensions::Daemon::TomcatWrapper do

  let(:tomcat_wrapper) do
    Trinidad::Extensions::Daemon::TomcatWrapper.new Trinidad::Tomcat::Tomcat.new
  end
  
  it "responds to tomcat methods" do
    tomcat_wrapper.respond_to?(:start).should be true
    tomcat_wrapper.respond_to?(:stop).should be true
    
    tomcat_wrapper.respond_to?(:base_dir=).should be true
    tomcat_wrapper.respond_to?(:setBaseDir).should be true
    
    tomcat_wrapper.respond_to?(:port=).should be true
    tomcat_wrapper.respond_to?(:setPort).should be true
  end
  
  it "configures a real tomcat" do
    wrapper = tomcat_wrapper
    tomcat = wrapper.instance_variable_get(:'@tomcat')
    
    wrapper.base_dir = '/base_dir'
    wrapper.hostname = 'local-host1'
    wrapper.server.address = 'local-host2'
    wrapper.port = 42
    wrapper.host.app_base = '/app-base'
    wrapper.enable_naming
    
    tomcat.basedir.should == '/base_dir'
    tomcat.hostname.should == 'local-host1'
    tomcat.server.address.should == 'local-host2'
    tomcat.port.should == 42
    tomcat.host.app_base.should == '/app-base'
  end
  
  context "mocked" do
    
    @@tmpdir = nil
    before :all do
      @@tmpdir = ENV['TMPDIR']
      ENV['TMPDIR'] = File.dirname(__FILE__)
    end
    
    after :all do
      ENV['TMPDIR'] = @@tmpdir
    end
    
    let(:tomcat) { mock('tomcat') }
    let(:tomcat_wrapper) do
      Trinidad::Extensions::Daemon::TomcatWrapper.new tomcat
    end
    
    it "starts tomcat" do
      current_pid = $$
      com.sun.akuma.Daemon::WithoutChdir.expects(:new).returns daemon = mock("daemon")
      daemon.expects(:isDaemonized).returns true
      daemon.expects(:init).with("#{File.dirname(__FILE__)}/trinidad.pid")

      tomcat.expects(:start)
      tomcat.expects(:server).returns server = mock("tomcat.server")
      server.expects(:await)

      tomcat_wrapper.start
    end

    it "stops tomcat" do
      tomcat.expects(:stop)
      tomcat_wrapper.stop
    end
    
  end
  
end
