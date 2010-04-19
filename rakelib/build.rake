require 'ant'
require 'fileutils'
include FileUtils

TARGET_DIR = 'target'
LIBS_DIR = 'trinidad-libs'
JAR_NAME = 'trinidad-daemon-extension.jar'

namespace :ant do
  desc 'Clean the java target directory'
  task :clean do
    rm_f TARGET_DIR
    rm_f "#{LIBS_DIR}/#{JAR_NAME}"
  end

  desc 'Compile the java classes'
  task :compile => :clean do
    opts = {
      :fork => 'true',
      :failonerror => 'true',
      :srcdir => 'src/main/java',
      :destdir => TARGET_DIR,
      :classpath => Dir.glob('trinidad-libs/*.jar').join(':')
    }

    mkdir_p TARGET_DIR
    ant.javac(opts)
  end

  desc 'Create the jar file'
  task :build => :compile do
    opts = {
      :destfile => "#{LIBS_DIR}/#{JAR_NAME}",
      :basedir => TARGET_DIR
    }
    ant.jar(opts)
  end
end
